//
//  ViewController.swift
//  Diary
//
//  Created by 최진안 on 2023/05/13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - collectionview 설정
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
            
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

// MARK: - WriteDiaryViewDelegate를 확장해서 채택해야 위에 prepare에서 사용가능함
extension ViewController: WriteDiaryViewDelegate {
    
    // 일기작성화면에 일기가 작성될때마다 diary배열에 일기내용 객체들이 추가가 된다.
    func didSelectRegister(diary: Diary) {
        self.diaryList.append(diary)
    }
    
}
