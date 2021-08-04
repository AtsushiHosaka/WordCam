//
//  WordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/24.
//

import UIKit
import Eureka

class WordViewController: FormViewController {
    
    var word: Word?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        form
            +++ Section("単語")
            <<< WordTitleRow() {
                $0.cell.titleLabel.text = word?.word
                $0.cell.backgroundColor = nil
            }
            
            +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "意味", footer: "") {
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
                    $0.title = word?.word
                }
            }
        
            +++ Section("正答率")
            <<< WordChartRow() {
                $0.cell.data = word?.correctAnsRate
                
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
//    @IBAction func saveBtnPressed() {
//        if let items = self.form.rowBy(tag: "meanings") as? MultivaluedSection {
//            print(items.values())
//        }
//    }
    
}

