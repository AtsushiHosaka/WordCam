//
//  EditSetViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/20.
//

import UIKit
import ISEmojiView

class EditSetViewController: UIViewController {
    
    let realm = RealmService.shared.realm
    var set = Sets()
    var selectedColor: Int?
    var reloadCollectionView: (() -> Void)?
    @IBOutlet var backgroundLabel: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emojiField: UITextField!
    @IBOutlet var colorCollection: UICollectionView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var emojiBackground: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTextField()
        setupLabel()
        setupButton()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
        
        reloadTextField()
        reloadLabel()
    }
    
    func setupCollectionView() {
        colorCollection.dataSource = self
        colorCollection.delegate = self
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        colorCollection.collectionViewLayout = collectionLayout
    }
    
    func setupTextField() {
        nameField.delegate = self
        emojiField.delegate = self
        
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        emojiField.inputView = emojiView
        
        NotificationCenter.default.addObserver(self,selector: #selector(textFieldDidChange(notification:)),name: UITextField.textDidChangeNotification,object: emojiField)
    }
    
    func setupLabel() {
        backgroundLabel.layer.cornerRadius = 30
        backgroundLabel.clipsToBounds = true
    }
    
    func setupButton() {
        cancelButton.layer.cornerRadius = 20
        finishButton.layer.cornerRadius = 20
    }
    
    func reloadData() {
        let setID = UserDefaults.standard.string(forKey: "setID")
        set = realm.object(ofType: Sets.self, forPrimaryKey: setID) ?? Sets()
        
        selectedColor = set.color
    }
    
    func reloadTextField() {
        nameField.text = set.title
        emojiField.text = set.emoji
    }
    
    func reloadLabel() {
        if set.emoji == "" {
            emojiBackground.isHidden = false
        }else {
            emojiBackground.isHidden = true
        }
    }
    
    @objc func textFieldDidChange(notification: NSNotification) {
        let textField = notification.object as! UITextField

        if let text = textField.text {
            if textField.markedTextRange == nil && text.count > 1 {
                let str = text.reversed()
                textField.text = String(str.prefix(1))
            }
        }
    }
    
    @IBAction func finishButtonPressed() {
        if nameField.text != "" && emojiField.text != "" {
            RealmService.shared.update(set, with: ["title": nameField.text!, "color": selectedColor ?? 0, "emoji": emojiField.text!])
            
            reloadCollectionView!()
            self.dismiss(animated: true, completion: nil)
        }else {
            let alert = UIAlertController(title: "エラー", message: "全ての項目に入力してください", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed() {
        reloadCollectionView!()
        self.dismiss(animated: true, completion: nil)
    }

}

extension EditSetViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Color.shared.endColors.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.layer.backgroundColor = Color.shared.colorCG(num: indexPath.row, type: 1)
        if selectedColor != nil {
            if selectedColor == indexPath.row {
                cell.layer.borderWidth = 3.0
            }else {
                cell.layer.borderWidth = 0.0
            }
            cell.layer.borderColor = Color.shared.mainColor.cgColor
        }
        return cell
    }
}

extension EditSetViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = indexPath.row
        colorCollection.reloadData()
    }
}

extension EditSetViewController: EmojiViewDelegate {
    // callback when tap a emoji on keyboard
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        emojiField.insertText(emoji)
    }

    // callback when tap change keyboard button on keyboard
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        emojiField.inputView = nil
        emojiField.keyboardType = .default
        emojiField.reloadInputViews()
    }
        
    // callback when tap delete button on keyboard
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        emojiField.deleteBackward()
    }

    // callback when tap dismiss button on keyboard
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        emojiField.resignFirstResponder()
    }

}

extension EditSetViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emojiBackground.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if emojiField.text?.count == 0 {
            emojiBackground.isHidden = false
        }
    }
}
