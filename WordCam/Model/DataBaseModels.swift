//
//  WordsModel.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/16.
//

import Foundation
import RealmSwift

class Word: Object {
    @objc dynamic var wordID = UUID().uuidString
    @objc dynamic var word: String = ""
    @objc dynamic var meaning: String = ""
    
    let sets = List<Sets>()
    
    let wordAnsHistory = LinkingObjects(fromType: WordAnsHistory.self, property: "word")
    let correctAnsRate = List<WordAnsHistory>()
    
    convenience init(word: String, meaning: String) {
        self.init()
        self.word = word
        self.meaning = meaning
    }
    
    override static func primaryKey() -> String? {
        return "wordID"
    }
}

class Sets: Object {
    @objc dynamic var setID = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var emoji: String = ""
    
    let word = LinkingObjects(fromType: Word.self, property: "sets")
    var words = List<Word>()
    
    let setAnsHistory = LinkingObjects(fromType: SetAnsHistory.self, property: "set")
    var correctAnsRate = List<SetAnsHistory>()
    
    convenience init(title: String, color: String, emoji: String) {
        self.init()
        self.title = title
        self.color = color
        self.emoji = emoji
    }
    
    override static func primaryKey() -> String? {
        return "setID"
    }
}

class WordAnsHistory: Object {
    @objc dynamic var wordAnsHistoryID = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var rate: Double = 0
    
    let word = List<Word>()
    
    convenience init(date: Date, rate: Double) {
        self.init()
        self.date = date
        self.rate = rate
    }
    
    override static func primaryKey() -> String? {
        return "wordAnsHistoryID"
    }
}

class SetAnsHistory: Object {
    @objc dynamic var setAnsHistoryID = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var rate: Double = 0
    
    let set = List<Sets>()
    
    convenience init(date: Date, rate: Double) {
        self.init()
        self.date = date
        self.rate = rate
    }
    
    override static func primaryKey() -> String? {
        return "setAnsHistoryID"
    }
}
