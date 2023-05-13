//
//  ViewController.swift
//  Diary
//
//  Created by 최진안 on 2023/05/13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - diaryList배열에 추가될때마다 저장되도록 한다.
    private var diaryList = [Diary]() {
        didSet {
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
        // 관찰자 옵저버 추가
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
    }
    
    // MARK: - collectionview 설정
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let row  = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.diaryList[row] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let indexPath = starDiary["indexPath"] as? IndexPath else { return }
        self.diaryList[indexPath.row].isStar = isStar
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
            
    }
    
    // MARK: - 일기 저장 -> 앱을 재시작해도 일기가 사라지지않도록 코드작성
    private func saveDiaryList() {
        let date = self.diaryList.map {
            [
                "title": $0.title,
                "contents": $0.contents,
                "date":$0.date,
                "isStar":$0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "diaryList")
    }
    
    // MARK: - 일기 내용을 로드한다.
    private func loadDiaryList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else {
            return
        }
        // dictionary 타입에 접근해서 데이터를 세팅해 준다.
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }
        self.diaryList = self.diaryList.sorted(by: {
            // 왼쪽 오른쪽 비교해서 내림차순으로 정렬실시 -> 최신순으로 정렬됨
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    // MARK: - 데이터 타입을 전달받으면 문자열로 변환시켜주는 메서드 선언
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR") // 한국어로 표시되게함
        return formatter.string(from: date)
    }
}

// MARK: - collectionView 데이터 설정 확장선언
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 재사용 가능한 collectionview전용 셀을 찾아온다.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell()}
        // 배열에 저장된 객체를 가져온다.
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

// MARK: - collectionView 델리게이트 채택
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}

// MARK: - 일기 선택시 상세항목으로 이동시키는 기능 구현을 위해 delegate 채택
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - WriteDiaryViewDelegate를 확장해서 채택해야 위에 prepare에서 사용가능함
extension ViewController: WriteDiaryViewDelegate {
    
    // 일기작성화면에 일기가 작성될때마다 diary배열에 일기내용 객체들이 추가가 된다.
    func didSelectRegister(diary: Diary) {
        self.diaryList.append(diary)
        // 일기가 추가된 뒤 날짜를 최신순으로 정렬한다.
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        // 일기가 추가될때마다 collectionView를 reload시킨다.
        self.collectionView.reloadData()
    }
    
}

extension ViewController: DiaryDetailViewDelegate {
    
    func didSelectDelete(indexPath: IndexPath) {
        self.diaryList.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
    }

}
