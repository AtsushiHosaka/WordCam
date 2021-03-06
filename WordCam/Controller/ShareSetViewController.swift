//
//  ShareSetViewController.swift
//  ShareSetViewController
//
//  Created by 保坂篤志 on 2021/10/08.
//

import UIKit

class ShareSetViewController: UIViewController {
    
    var isShared: Bool = false
    var setID: String = ""
    @IBOutlet var IDLabel: UILabel!
    @IBOutlet var copyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
        
        reloadLabel()
        
        if !isShared {
            showShareAlert()
        }
    }
    
    func setupButton() {
        copyButton.setTitle("", for: .normal)
        copyButton.layer.cornerRadius = copyButton.bounds.height / 2
    }
    
    func reloadData() {
        setID = UserDefaults.standard.string(forKey: "setID") ?? ""
    }
    
    func reloadLabel() {
        IDLabel.text = String(setID.prefix(18)) + "\n" + String(setID.suffix(18))
    }
    
    @IBAction func copyID() {
        UIPasteboard.general.string = setID
        showCopiedAlert()
    }
    
    func showShareAlert() {
        let set = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID) ?? WordSet()
        
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            FirebaseAPI.shared.addOriginalSetToFirebase(ID: self.setID, set: set)
            self.updateRealmData()
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: {(action: UIAlertAction!) -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        let alert = MyAlert.shared.customAlert(title: "セットを共有しますか？", message: "", style: .alert, action: [action, cancel])
        present(alert, animated: true, completion: nil)
    }
    
    func showCopiedAlert() {
        let alert = UIAlertController(title: "IDがコピーされました", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateRealmData() {
        print(setID)
        guard let set = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID) else { return }
        RealmService.shared.update(set, with: ["isShared": 1])
    }
    
}
