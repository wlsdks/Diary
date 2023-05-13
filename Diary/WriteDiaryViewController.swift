//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 최진안 on 2023/05/13.
//

import UIKit

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContentsTextView()
    
    }
    
    private func configureContentsTextView() {
        let borderColor = UIColor(displayP3Red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        
        // layer관련 설정은 cgColor로 해줘야함
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        
    }
    
}
