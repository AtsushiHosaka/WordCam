//
//  WordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/24.
//

import UIKit
import RealmSwift
import Eureka

class WordViewController: FormViewController {
    
    var word: Word?
    
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
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupEureka() {
        form
            +++ Section("単語")
            <<< TextRow() {
                $0.tag = "word"
                $0.value = word?.word
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
                for meaning in word!.meanings {
                    let row = MeaningRow() {
                        $0.cell.meaningTextField.text = meaning.meaning
                        $0.cell.selectedNum = meaning.type
                        let str = $0.cell.data[meaning.type]
                        $0.cell.typeTextField.text = String(str[str.startIndex])
                    }
                    $0.append(row)
                }
            }
        
            if word?.correctAnsRate.count != 0 {
                form
                    +++ Section("正答率")
                    <<< WordChartRow() {
                        $0.cell.data = word?.correctAnsRate
                    }
            }
        
        form
            +++ Section()
            <<< ButtonRow() {
                $0.title = "変更を保存"
                $0.onCellSelection {_, _ in
                    self.saveWord()
                }
            }
        
        tableView.backgroundColor = Color.shared.backgroundColor
    }
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.title = word?.word
    }
    
    @IBAction func deleteButtonPressed() {
        let alert = UIAlertController(title: "単語を削除しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.deleteWord()
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(str: String) {
        let alert = UIAlertController(title: "エラー", message: str, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveWord() {
        guard let wordValue = (form.rowBy(tag: "word") as? TextRow)?.value else {
            showErrorAlert(str: "すべての項目に入力してください")
            return
        }
        guard let meaningsValue: [String] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? MeaningRow)?.cell.meaningTextField.text }) else {
            showErrorAlert(str: "すべての項目に入力してください")
            return
        }
        
        guard let typesValue: [Int] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? MeaningRow)?.cell.selectedNum }) else {
            showErrorAlert(str: "すべての項目に入力してください")
            return
        }
        
        for meaning in meaningsValue {
            if meaning.count > 10 {
                showErrorAlert(str: "意味は10文字以内にしてください")
                return
            }
        }
        
        guard let word = word else {
            showErrorAlert(str: "すべての項目に入力してください")
            return
        }
        
        var meanings = [Meaning]()
        for i in 0..<meaningsValue.count {
            meanings.append(Meaning(meaning: meaningsValue[i], type: typesValue[i]))
        }
        
        RealmService.shared.update(word, with: ["word": wordValue, "meanings": meanings])
                
        self.navigationController?.popViewController(animated: true)
    }
    
    func deleteWord() {
        guard let word = word else { return }
        RealmService.shared.delete(word)
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

