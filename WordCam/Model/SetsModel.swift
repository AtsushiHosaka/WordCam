//
//  SetModel.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/16.
//

import UIKit
import RealmSwift

class Sets: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var correctAnsRate: Int = 0
    @objc dynamic var color: String = ""
    @objc dynamic var emoji: String = ""
    var words = List<Word>()
}
