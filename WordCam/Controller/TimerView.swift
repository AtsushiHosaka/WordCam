//
//  TimerView.swift
//  TimerView
//
//  Created by 保坂篤志 on 2021/09/21.
//

import UIKit

class TimerView: UIView {
    
    let shapeLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    var timeRimit: Int = 0
    
    func setupAnimation() {
        animation.toValue = 0
        animation.duration = CFTimeInterval(timeRimit)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
    }
    
    func showShape() {
        let trackLayer = CAShapeLayer()
        let trackPath = UIBezierPath()
        trackPath.move(to: CGPoint(x: 60, y: self.bounds.height / 2))
        trackPath.addLine(to: CGPoint(x: self.bounds.width - 70, y: self.bounds.height / 2))
        
        trackLayer.path = trackPath.cgPath
        trackLayer.strokeColor = CGColor(red: 65/255, green: 67/255, blue: 89/255, alpha: 1.0)
        trackLayer.backgroundColor = nil
        trackLayer.lineWidth = 50
        trackLayer.lineCap = .round
        
        self.layer.addSublayer(trackLayer)
        
        let traceLayer = CAShapeLayer()
        let tracePath = UIBezierPath()
        tracePath.move(to: CGPoint(x: 60, y: self.bounds.height / 2))
        tracePath.addLine(to: CGPoint(x: self.bounds.width - 70, y: self.bounds.height / 2))
        
        traceLayer.path = trackPath.cgPath
        traceLayer.strokeColor = CGColor(red: 28/255, green: 40/255, blue: 103/255, alpha: 1.0)
        traceLayer.backgroundColor = nil
        traceLayer.lineWidth = 40
        traceLayer.lineCap = .round
        
        self.layer.addSublayer(traceLayer)
        
        let shapePath = UIBezierPath()
        shapePath.move(to: CGPoint(x: 60, y: self.bounds.height / 2))
        shapePath.addLine(to: CGPoint(x: self.bounds.width - 70, y: self.bounds.height / 2))
        
        shapeLayer.path = shapePath.cgPath
        shapeLayer.strokeColor = CGColor(red: 188/255, green: 0, blue: 160/255, alpha: 1.0)
        shapeLayer.backgroundColor = nil
        shapeLayer.lineWidth = 40
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 1
        
        self.layer.addSublayer(shapeLayer)
        
        shapeLayer.add(animation, forKey: "animation")
    }
    
    func pauseAnimation() {
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
    }

    func resumeAnimation() {
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        let timeSincePause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePause
    }
    
    func initAnimation() {
        shapeLayer.strokeEnd = 1
        shapeLayer.add(animation, forKey: "animation")
    }
}
