//
//  CustomAlertViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/11.
//

import UIKit
import RealmSwift

class AddSetViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emojiField: UITextField!
    @IBOutlet var colorCollection: UICollectionView!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var addBtn: UIButton!
    let color = Color()
    var selectedColor: Int?
    
    var reloading: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorCollection.dataSource = self
        colorCollection.delegate = self
        nameField.delegate = self
        emojiField.delegate = self
        
        backgroundLabel.layer.cornerRadius = 30
        backgroundLabel.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 20
        addBtn.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameField.text = ""
        emojiField.text = ""
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return color.colorValues.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.layer.backgroundColor = color.colorCG(num: indexPath.row)
        if selectedColor != nil {
            if selectedColor == indexPath.row {
                cell.layer.borderWidth = 3.0
            }else {
                cell.layer.borderWidth = 0.0
            }
            cell.layer.borderColor = CGColor(red: 28/255, green: 40/255, blue: 103/255, alpha: 1.0)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = indexPath.row
        colorCollection.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func addBtnPressed() {
        if nameField.text != "" && emojiField.text != "" {
            let set = Sets(title: nameField.text!, color: selectedColor ?? 0, emoji: emojiField.text!)
            RealmService.shared.create(set)
            
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
