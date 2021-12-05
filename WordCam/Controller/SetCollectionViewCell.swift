//
//  SetCollectionViewCell.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/19.
//

import UIKit

class SetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var correctAnsRateLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    
    var setData = WordSet() {
        didSet {
            titleLabel.text = setData.title
            emojiLabel.text = setData.emoji
            editButton.setTitle("", for: .normal)
            gradientView.startColor = MyColor.shared.colorUI(num: setData.color, type: 0)
            gradientView.endColor = MyColor.shared.colorUI(num: setData.color, type: 1)
            gradientView.layer.setNeedsDisplay()
            correctAnsRateLabel.text = String(Int(setData.correctAnsRateAverage * 100)) + "%"
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 12.0
        self.layer.cornerCurve = .continuous
        self.contentView.isUserInteractionEnabled = false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled else { return nil }
        guard !isHidden else { return nil }
        guard alpha >= 0.01 else { return nil }
        guard self.point(inside: point, with: event) else { return nil }
        if self.editButton.point(inside: convert(point, to: editButton), with: event) {
            return self.editButton
        }
        return super.hitTest(point, with: event)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
