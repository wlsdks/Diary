//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 최진안 on 2023/05/13.
//

import UIKit

enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

// MARK: - 프로토콜 선언
protocol WriteDiaryViewDelegate: AnyObject {
    // 파라미터에 일기 내용이 작성된 diary 객체를 전달한다.
    func didSelectRegister(diary: Diary)
}


class WriteDiaryViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    // 날짜관련 변수선언
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    weak var delegate: WriteDiaryViewDelegate?
    var diaryEditorMode: DiaryEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContentsTextView()
        configureDatePicker()
        configureInputField()
        configureEditMode()
        // 등록버튼을 비활성화 시켜준다.
        self.confirmButton.isEnabled = false
        
    }
    
    private func configureEditMode() {
        switch self.diaryEditorMode {
        case let .edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
            
        default:
            break
        }
    }
    
    // MARK: - 데이터 타입을 전달받으면 문자열로 변환시켜주는 메서드 선언
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR") // 한국어로 표시되게함
        return formatter.string(from: date)
    }
    
    private func configureContentsTextView() {
        let borderColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        
        // layer관련 설정은 cgColor로 해줘야함
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    // MARK: - datePicker 설정코드
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        // 값이 변경될때(for로 설정해줌) #selector내부의 함수가 호출된다.
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko-KR")
        // dateTextField를 선택하면 키보드가 아닌 datePicker가 나오도록 설정
        self.dateTextField.inputView = self.datePicker
    }
    
    // input필드 검증하는 메서드
    private func configureInputField() {
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        // datePicker는 키보드로 입력을 받지 않다보니 .editingChanged를 발생시키려면 sendActions코드 작성이 필요하다
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - 등록버튼 클릭시 동작
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        // 위에서 선언한 값들을 담아준다.
        
        // switch문으로 NotificationCenter를 사용하도록 하고 new 와 edit을 구분해서 각각 다른동작을 하도록 코드를 구현함
        switch self.diaryEditorMode {
        case .new:
            let diary = Diary(
                uuidString: UUID().uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: false
            )
            self.delegate?.didSelectRegister(diary: diary)
            
        case let .edit(indexPath, diary):
            let diary = Diary(
                uuidString: UUID().uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: diary.isStar
            )
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: nil
            )
        
        }
        
        // 일기장 화면으로 이동되도록 해준다.
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        // DateFormatter는 날짜를 사람이 읽을수 있는 형태로 변환해줌 또는 날짜를 date타입으로 변환시켜줌
        let formmater = DateFormatter()
        // 아래 코드처럼 formmat 형식을 적어주면 된다.
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        // 이제 코드안에 date값을 설정해 준다.
        self.diaryDate = datePicker.date
        self.dateTextField.text = formmater.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    // 제목이 입력될때마다 등록버튼 활성화 여부를 검증하는 메서드
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    // 날짜를 선택할때(변경될때)마다 등록버튼 활성화 여부를 검증하는 메서드
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    
    // 빈 화면을 눌러주면 키보드나 datepicker가 사라진다.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // InputField 내용이 있는지 검증하는 코드 - true, false반환
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
    }
}

// MARK: - 텍스트 delegate 확장 선언
extension WriteDiaryViewController: UITextViewDelegate {
    // textview에 text가 입력 될때마다 호출되는 메서드다.
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
