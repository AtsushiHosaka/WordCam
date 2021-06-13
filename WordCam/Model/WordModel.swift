//
//  WordsModel.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/16.
//

import Foundation
import RealmSwift

class Word: Object {
    @objc dynamic var english: String = ""
    @objc dynamic var meaning: String = ""
    let identifierNum: Int = 0
    @objc dynamic var correctAnsRate: Float = 0
}


