//
//  InputWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/15.
//

import UIKit
import Eureka

class InputWordViewController: FormViewController {
    
    let realm = RealmService.shared.realm
    let color = Color()
    var words = [String]()
    var currentNum = 0

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
                    return TextRow() {
                        $0.placeholder = "意味を入力してください"
                    }
                }
                $0 <<< TextRow() {
                    $0.placeholder = "意味を入力してください"
                }
            }
        
        tableView.backgroundColor = color.backgroundColor
    }
    
    @IBAction func cancelButtonPressed() {
        let alert = UIAlertController(title: "キャンセル", message: "'\(words[currentNum])'の追加を中止します", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.showNext()
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed() {
        saveWord()
        showNext()
    }
    
    func startSetting() {
        currentNum = -1
        
        showNext()
    }
    
    func showNext() {
        currentNum += 1
        if currentNum >= words.count {
            endInputting()
        }else {
            let data = realm.objects(Word.self)
            var wordData = [String]()
            for d in data {
                wordData.append(d.word)
            }
            
            if !wordData.contains(words[currentNum]) {
                let wordRow = self.form.rowBy(tag: "word") as! TextRow
                wordRow.value = words[currentNum]
                wordRow.reload()
                
                var meaningsSection = self.form.sectionBy(tag: "meanings") as! MultivaluedSection
                for _ in 0..<meaningsSection.count - 1 {
                    meaningsSection.removeFirst()
                }
                let row = TextRow() {
                    $0.placeholder = "意味を入力してください"
                }
                meaningsSection.insert(row, at: 0)
                meaningsSection.reload()
            }else {
                showUnableAlert(word: words[currentNum])
            }
        }
    }
    
    func endInputting() {
        let num = (self.navigationController?.viewControllers.count)! - 3
        navigationController?.popToViewController(navigationController!.viewControllers[num], animated: true)
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "エラー", message: "全ての項目に入力してください", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showUnableAlert(word: String) {
        let alert = UIAlertController(title: "エラー", message: "すでに'\(word)'は追加されています", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.showNext()
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveWord() {
        guard let inputtedValue = (form.rowBy(tag: "word") as? TextRow)?.value else {
            showErrorAlert()
            return
        }
        let wordValue = inputtedValue.trimmingCharacters(in: .whitespaces)
        
        guard let meaningsValue: [String] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? TextRow)?.value }) else {
            showErrorAlert()
            return
        }
        
        let word = Word(word: wordValue, meanings: meaningsValue)
        RealmService.shared.create(word)
    }

}
