//
//  ResultChartView.swift
//  ResultChartView
//
//  Created by 保坂篤志 on 2021/09/20.
//

import UIKit

class ResultChartView: UIView {
    
    var color: Int = 0
    
    var correctAnsRate: Double = 0 {
        didSet {
            showShape()
        }
    }
    
    func showShape() {
        let trackLayer = CAShapeLayer()
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let trackCircularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi*2, clockwise: true)
        
        trackLayer.path = trackCircularPath.cgPath
        trackLayer.strokeColor = UIColor.systemGray6.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 20
        
        self.layer.addSublayer(trackLayer)
        
        let shapeLayer = CAShapeLayer()
        let shapeCircularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi*2 * (CGFloat(correctAnsRate) - 0.25), clockwise: true)
        
        shapeLayer.path = shapeCircularPath.cgPath
        shapeLayer.strokeColor = MyColor.shared.colorCG(num: color, type: 1)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.strokeEnd = 0
        self.layer.addSublayer(shapeLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1
        animation.duration = 2
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        shapeLayer.add(animation, forKey: "animation")
    }
}
