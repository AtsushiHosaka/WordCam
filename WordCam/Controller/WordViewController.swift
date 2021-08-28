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
                    return TextRow() {
                        $0.placeholder = "意味を入力してください"
                    }
                }
                for meaning in word!.meanings {
                    let row = TextRow() {
                        $0.value = meaning
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
        guard let meaningsValue: [Any] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? TextRow)?.value }) else {
            showErrorAlert(str: "すべての項目に入力してください")
            return
        }
        
        for meaning in meaningsValue {
            let meaning = meaning as! String
            if meaning.count > 10 {
                showErrorAlert(str: "意味は10文字以内にしてください")
                return
            }
        }
        
        guard let word = word else {
            showErrorAlert(str: "すべての項目に入力してください")
            return
        }
        
        RealmService.shared.update(word, with: ["word": wordValue, "meanings": meaningsValue])
            
        self.navigationController?.popViewController(animated: true)
    }
    
    func deleteWord() {
        guard let word = word else { return }
        RealmService.shared.delete(word)
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

