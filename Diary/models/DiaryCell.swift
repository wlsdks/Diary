//
//  DiaryCell.swift
//  Diary
//
//  Created by 최진안 on 2023/05/13.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        // 테두리는 cgColor사용
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
    
    
    
}
