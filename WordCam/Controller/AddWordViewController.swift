//
//  AddWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/04.
//

import UIKit
import Eureka

class AddWordViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupEureka()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadNavigationController()
    }
    
    func setupNavigationController() {
        self.title = "単語を追加"
    }
    
    func setupEureka() {
        form
            +++ Section("単語")
            <<< TextRow() {
                $0.tag = "word"
            }
            
            +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "意味", footer: "一番上にある意味がクイズに出題されます") {
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
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @IBAction func addBtnPressed() {
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
        
        if  isNewWord(word: wordValue){
            let word = RealmService.shared.createWord(wordValue: wordValue, meaningsValue: meaningsValue, typesValue: typesValue)
            RealmService.shared.create(word)
            
            self.navigationController?.popViewController(animated: true)
        }else {
            showErrorAlert(message: "すでにこの単語は追加されています")
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = MyAlert.shared.errorAlert(message: message)
        present(alert, animated: true, completion: nil)
    }
    
    func isNewWord(word: String) -> Bool {
        let words = RealmService.shared.realm.objects(Word.self)
        var wordsArray = [String]()
        for word in words {
            wordsArray.append(word.word)
        }
        
        if !wordsArray.contains(word) {
            return true
        }else {
            return false
        }
    }
}
