//
//  InputWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/15.
//

import UIKit
import Eureka

class InputWordViewController: FormViewController {
    
    var words = [String]()
    var meaning = "" {
        didSet {
            reloadEureka()
        }
    }
    var currentNum = 0
    //0: toWords 1: toSet
    var type: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupEureka()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startSetting()
    }
    
    func setupNavigationController() {
        self.title = "単語を追加"
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupEureka() {
        form
            +++ Section("単語")
            <<< TextRow() {
                $0.tag = "word"
                $0.value = words[currentNum]
            }
            
            +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "意味", footer: "一番上の意味がクイズに出題されます") {
                $0.tag = "meanings"
                $0.addButtonProvider = { section in
                    return ButtonRow() {
                        $0.title = "＋"
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    return MeaningRow() {
                        $0.cell.selectedNum = 0
                    }
                }
                $0 <<< MeaningRow() {
                    $0.cell.selectedNum = 0
                }
            }
        
        tableView.backgroundColor = MyColor.shared.backgroundColor
    }
    
    @IBAction func cancelButtonPressed() {
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.showNext()
        })
        let alert = MyAlert.shared.customAlert(title: "キャンセル", message: "'\(words[currentNum])'の追加を中止します", style: .alert, action: [action])
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed() {
        saveWord()
    }
    
    func startSetting() {
        currentNum = -1
        
        showNext()
    }
    
    func reloadEureka() {
        DispatchQueue.main.async {
            let data = RealmService.shared.realm.objects(Word.self)
            var wordData = [String]()
            for d in data {
                wordData.append(d.word)
            }
            
            let wordRow = self.form.rowBy(tag: "word") as! TextRow
            wordRow.value = self.words[self.currentNum]
            wordRow.reload()
            
            if wordData.contains(self.words[self.currentNum]) {
                self.showErrorAlert(message: "すでに'\(self.words[self.currentNum])'は追加されています")
            }
                
            var meaningsSection = self.form.sectionBy(tag: "meanings") as! MultivaluedSection
            for _ in 0..<meaningsSection.count - 1 {
                meaningsSection.removeFirst()
            }
            
            let meaningRow = MeaningRow {
                $0.cell.meaningTextField.text = self.meaning
                $0.cell.selectedNum = 0
            }
            meaningsSection.insert(meaningRow, at: 0)
            
            meaningRow.reload()
        }
    }
    
    func getMeaning() {
        SwiftGoogleTranslate.shared.translate(words[currentNum], "ja", "en") { (text, error) in
            if let text = text {
                self.meaning = text
            }
        }
    }
    
    func showNext() {
        currentNum += 1
        if currentNum >= words.count {
            endInputting()
        }else {
            getMeaning()
        }
    }
    
    func endInputting() {
        let num = (self.navigationController?.viewControllers.count)! - 3
        navigationController?.popToViewController(navigationController!.viewControllers[num], animated: true)
    }
    
    func showErrorAlert(message: String) {
        let alert = MyAlert.shared.errorAlert(message: message)
        present(alert, animated: true, completion: nil)
    }
    
    func saveWord() {
        guard let inputtedValue = (form.rowBy(tag: "word") as? TextRow)?.value else {
            showErrorAlert(message: "すべての項目に入力してください")
            return
        }
        let wordValue = inputtedValue.trimmingCharacters(in: .whitespaces)
        
        guard let meaningsValue: [String] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? MeaningRow)?.cell.meaningTextField.text }) else {
            showErrorAlert(message: "すべての項目に入力してください")
            return
        }
        
        guard let typesValue: [Int] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? MeaningRow)?.cell.selectedNum }) else {
            showErrorAlert(message: "すべての項目に入力してください")
            return
        }
        
        for meaning in meaningsValue {
            if meaning.count > 10 {
                showErrorAlert(message: "意味は10文字以内にしてください")
                return
            }
        }
        
        let word = RealmService.shared.createWord(wordValue: wordValue, meaningsValue: meaningsValue, typesValue: typesValue)
        RealmService.shared.create(word)
        
        if type == 1 {
            let setID = UserDefaults.standard.string(forKey: "setID") ?? ""
            RealmService.shared.addWordsToSet(setID: setID, words: [word])
        }
        showNext()
    }

}

