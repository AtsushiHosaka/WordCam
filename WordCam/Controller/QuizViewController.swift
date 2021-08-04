//
//  QuizViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/04.
//

import UIKit

class QuizViewController: UIViewController {
    
    var set = Sets()
    var questionCount: Int?
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var timeBarBackgroundLabel: UILabel!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var timeBar: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 28/255, green: 40/255, blue: 103/255, alpha: 1.0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        timeBar.transform = CGAffineTransform(scaleX: 1.0, y: 15.0)
        timeBar.layer.cornerRadius = timeBar.bounds.height / 2
        timeBar.clipsToBounds = true
        timeBarBackgroundLabel.layer.cornerRadius = timeBarBackgroundLabel.bounds.height / 2
        timeBarBackgroundLabel.clipsToBounds = true
        
        button1.layer.borderWidth = 5.0
        button2.layer.borderWidth = 5.0
        button3.layer.borderWidth = 5.0
        button4.layer.borderWidth = 5.0
        button1.layer.borderColor = CGColor(red: 31/255, green: 71/255, blue: 107/255, alpha: 1.0)
        button2.layer.borderColor = CGColor(red: 31/255, green: 71/255, blue: 107/255, alpha: 1.0)
        button3.layer.borderColor = CGColor(red: 31/255, green: 71/255, blue: 107/255, alpha: 1.0)
        button4.layer.borderColor = CGColor(red: 31/255, green: 71/255, blue: 107/255, alpha: 1.0)
        button1.layer.cornerRadius = 15
        button2.layer.cornerRadius = 15
        button3.layer.cornerRadius = 15
        button4.layer.cornerRadius = 15
    }
}
