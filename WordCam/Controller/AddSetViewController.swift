//
//  CustomAlertViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/11.
//

import UIKit
import RealmSwift

class AddSetViewController: UIViewController {
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emojiField: UITextField!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var addBtn: UIButton!
    
    var reloading: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundLabel.layer.cornerRadius = 30
        backgroundLabel.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 20
        addBtn.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameField.text = ""
        emojiField.text = ""
    }
    
    @IBAction func addBtnPressed() {
        if nameField.text != "" {
            let array: [String: Any] = ["title": nameField.text!,
                         "correctAnsRate": 0,
                         "emoji": emojiField.text!,
                         "color": "red"]
            let data = Sets(value: array)
            let realm = try! Realm()
            try! realm.write{
                realm.add(data)
            }
            reloading!()
            self.dismiss(animated: true, completion: nil)
        }else {
            //alert dasu
        }
    }
    
    @IBAction func cancelBtnPressed() {
        reloading!()
        self.dismiss(animated: true, completion: nil)
    }
    
   

}
