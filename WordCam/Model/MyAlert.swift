//
//  MyAlert.swift
//  MyAlert
//
//  Created by 保坂篤志 on 2021/09/03.
//

import UIKit

class MyAlert {
    
    static let shared = MyAlert()
    
    func errorAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        return alert
    }
    
    func customAlert(title: String, message: String, style: UIAlertController.Style, action: [UIAlertAction]) -> UIAlertController {
        var containsCancel = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in action {
            alert.addAction(action)
            if action.style == .cancel {
                containsCancel = true
            }
        }
        
        if !containsCancel {
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
        }
        
        return alert
    }
}
