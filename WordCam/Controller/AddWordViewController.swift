//
//  AddWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/25.
//

import UIKit
import Eureka

class AddWordViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section("section test")
             <<< TextRow() { row in
                row.title = "test2"
                
             }
             +++ Section("2")
    }

}
