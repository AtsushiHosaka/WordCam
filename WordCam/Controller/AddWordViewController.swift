//
//  AddWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/04.
//

import UIKit
import Eureka

class AddWordViewController: FormViewController {
    
    let color = Color()
    let realm = RealmService.shared.realm

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
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @IBAction func addBtnPressed() {
        guard let inputtedValue = (form.rowBy(tag: "word") as? TextRow)?.value else {
            showErrorAlert()
            return
        }
        let wordValue = inputtedValue.trimmingCharacters(in: .whitespaces)
        
        guard let meaningsValue: [String] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? TextRow)?.value }) else {
            showErrorAlert()
            return
        }

        let words = realm.objects(Word.self)
        var wordsArray = [String]()
        for data in words {
            wordsArray.append(data.word)
        }

        if !wordsArray.contains(String(wordValue)) {
            let word = Word(word: wordValue, meanings: meaningsValue)
            RealmService.shared.create(word)

            self.navigationController?.popViewController(animated: true)
        }else {
            showUnableAlert()
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "エラー", message: "全ての項目に入力してください", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showUnableAlert() {
        let alert = UIAlertController(title: "エラー", message: "すでにこの単語は追加されています", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}
