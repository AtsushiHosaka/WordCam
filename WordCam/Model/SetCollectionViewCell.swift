//
//  SetCollectionViewCell.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/16.
//

import UIKit

class SetCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var correctAnsRateLabel: UILabel!
    @IBOutlet var emojiLabel: UILabel!
    var deleteAlert: (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 12.0
        self.contentView.isUserInteractionEnabled = false
    }
    
    @IBAction func deleteButtonPressed() {
        deleteAlert?()
    }
}
