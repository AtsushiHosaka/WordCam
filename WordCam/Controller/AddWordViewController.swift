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
        
        //self.navigationController?.navigationBar.shadowImage = UIImage()

        form
            +++ Section("単語")
            <<< TextRow()
            
            +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete], header: "test", footer: "") {
                $0.addButtonProvider = { section in
                    return ButtonRow() {
                        $0.title = "＋"
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    return TextRow() {
                        //$0.tag = "meanings"
                        $0.placeholder = "意味を入力してください"
                    }
                }
                $0 <<< TextRow() {
                    //$0.tag = "meanings"
                    $0.placeholder = "意味を入力してください"
                }
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @IBAction func addBtnPressed() {
        let word = (form.rowBy(tag: "word") as? TextRow)?.value
        let meanings = (form.values())["meanings"] as? String
        print(word, meanings)
    }

}
