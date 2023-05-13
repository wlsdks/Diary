//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 최진안 on 2023/05/13.
//

import UIKit

class WriteDiaryViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    // 날짜관련 변수선언
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContentsTextView()
        configureDatePicker()
        // 등록버튼을 비활성화 시켜준다.
        self.confirmButton.isEnabled = false
        
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
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        
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
