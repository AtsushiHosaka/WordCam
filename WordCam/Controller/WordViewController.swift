//
//  WordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/24.
//

import UIKit
import RealmSwift
import Eureka
import NaturalLanguage

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
                        $0.cell.meaning = meaning
                    }
                    $0.append(row)
                }
            }
        
            if word?.correctAnsRate.count != 0 {
                form
                    +++ Section("正答率")
                    <<< WordChartRow() {
                        $0.cell.wordData = Array((word ?? Word()).correctAnsRate)
                        $0.cell.isUserInteractionEnabled = false
                    }
            }
        
        
            let neighborWords = NLEmbedding.wordEmbedding(for: .english)!.neighbors(for: word?.word ?? "", maximumCount: 5)
            let neighborSection = Section("意味が似ている単語")
            for word in neighborWords {
                let neighborRow = TextRow() {
                    $0.title = word.0
                    $0.baseCell.isUserInteractionEnabled = false
                }
                neighborSection.append(neighborRow)
            }
            form.append(neighborSection)
        
        form
            +++ Section()
            <<< ButtonRow() {
                $0.title = "変更を保存"
                $0.onCellSelection {_, _ in
                    self.saveWord()
                }
            }
        
        tableView.backgroundColor = MyColor.shared.backgroundColor
    }
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.title = word?.word
    }
    
    @IBAction func deleteButtonPressed() {
        let action = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.deleteWord()
        })
        let alert = MyAlert.shared.customAlert(title: "単語を削除しますか？", message: "", style: .alert, action: [action])
        present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String) {
        let alert = MyAlert.shared.errorAlert(message: message)
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveWord() {
        guard let wordValue = (form.rowBy(tag: "word") as? TextRow)?.value else {
            showErrorAlert(message: "すべての項目に入力してください")
            return
        }
        guard let meaningsValue: [String] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? MeaningRow)?.cell.meaningTextField.text }) else {
            showErrorAlert(message: "すべての項目に入力してください")
            return
        }
        
        for i in 0..<meaningsValue.count - 1 {
            for j in i+1..<meaningsValue.count {
                if meaningsValue[i] == meaningsValue[j] {
                    showErrorAlert(message: "同じ意味が追加されています")
                    return
                }
            }
        }
        
        guard let typesValue: [Int] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? MeaningRow)?.cell.selectedNum }) else {
            showErrorAlert(message: "すべての項目に入力してください")
            return
        }
        
        guard let word = word else {
            showErrorAlert(message: "エラーが発生しました")
            return
        }
        
        var meanings = [Meaning]()
        for i in 0..<meaningsValue.count {
            if meaningsValue[i].count > 10 {
                showErrorAlert(message: "意味は10文字以内にしてください")
                return
            }else {
                let meaning = Meaning(meaning: meaningsValue[i], type: typesValue[i], parentWord: word.word)
                meanings.append(meaning)
            }
        }
        
        for meaning in word.meanings {
            RealmService.shared.delete(meaning)
        }
        
        RealmService.shared.update(word, with: ["word": wordValue, "meanings": meanings])
                
        self.navigationController?.popViewController(animated: true)
    }
    
    func deleteWord() {
        for meaning in Array((word ?? Word()).meanings) {
            RealmService.shared.delete(meaning)
        }
        
        guard let word = word else { return }
        RealmService.shared.delete(word)
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

