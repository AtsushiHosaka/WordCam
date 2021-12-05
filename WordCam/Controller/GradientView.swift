//
//  GradientView.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/29.
//

import UIKit

@IBDesignable
final class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    var orientation: Orientation = .vertical

    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(
            x: CGFloat(0),
            y: CGFloat(0),
            width: self.frame.size.width,
            height: self.frame.size.height)
        gradient.colors = [self.startColor.cgColor, self.endColor.cgColor]
        gradient.zPosition = -1
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.addSublayer(gradient)
    }
    
    override func didChangeValue(forKey key: String) {
        self.draw(self.bounds)
    }
    
    
    enum Orientation: Int {
        case vertical = 0
        case horizontal = 1
        
        var startPoint: CGPoint {
            switch self {
            case .vertical:
                return CGPoint(x: 0.5, y: 0)
            case .horizontal:
                return CGPoint(x: 0, y: 0.5)
            }
        }
        
        var endPoint: CGPoint {
            switch self {
            case .vertical:
                return CGPoint(x: 0.5, y: 1)
            case .horizontal:
                return CGPoint(x: 1, y: 0.5)
            }
        }
    }
}
