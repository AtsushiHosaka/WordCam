//
//  CustomAlertViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/11.
//

import UIKit
import ISEmojiView

class AddSetViewController: UIViewController {
    
    var selectedColor: Int?
    var reloadCollectionView: (() -> Void)?
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emojiField: UITextField!
    @IBOutlet var colorCollection: UICollectionView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var emojiBackground: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTextField()
        setupBackgroudView()
        setupButton()
    }// オブザーバの破棄
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func setupBackgroudView() {
        backgroundView.layer.cornerRadius = 30
        backgroundView.layer.cornerCurve = .continuous
    }
    
    func setupButton() {
        cancelButton.layer.cornerRadius = 20
        addButton.layer.cornerRadius = 20
        cancelButton.layer.cornerCurve = .continuous
        addButton.layer.cornerCurve = .continuous
    }
    
    func reloadTextField() {
        nameField.text = ""
        emojiField.text = ""
    }
    
    func reloadLabel() {
        emojiBackground.isHidden = false
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
    
    @IBAction func addBtnPressed() {
        if nameField.text != "" && emojiField.text != "" {
            let set = Sets(title: nameField.text!, color: selectedColor ?? 0, emoji: emojiField.text!)
            RealmService.shared.create(set)
            
            reloadCollectionView!()
            self.dismiss(animated: true, completion: nil)
        }else {
            let alert = UIAlertController(title: "エラー", message: "全ての項目に入力してください", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnPressed() {
        reloadCollectionView!()
        self.dismiss(animated: true, completion: nil)
    }

}

extension AddSetViewController: UICollectionViewDataSource {
    
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

extension AddSetViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = indexPath.row
        colorCollection.reloadData()
    }
}

extension AddSetViewController: EmojiViewDelegate {
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

extension AddSetViewController: UITextFieldDelegate {
    
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
