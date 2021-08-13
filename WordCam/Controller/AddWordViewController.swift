//
//  AddWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/04.
//

import UIKit
import RealmSwift
import Eureka

class AddWordViewController: FormViewController {
    
    let color = Color()

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        tableView.isEditing = false
        tableView.backgroundColor = color.backgroundColor
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "エラー", message: "全ての項目に入力してください", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addBtnPressed() {
        guard let wordValue = (form.rowBy(tag: "word") as? TextRow)?.value else {
            showAlert()
            return
        }
        guard let meaningsValue: [String] = (form.sectionBy(tag: "meanings")?.compactMap { ($0 as? TextRow)?.value }) else {
            showAlert()
            return
        }
        //wordsに含まれているか
            let word = Word(word: wordValue, meanings: meaningsValue)
            RealmService.shared.create(word)
                
            self.navigationController?.popViewController(animated: true)
    }

}
