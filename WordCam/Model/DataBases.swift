//
//  WordsModel.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/16.
//

import Foundation
import RealmSwift

let b = 1

class Meaning: Object {
    @objc dynamic var meaning: String = ""
    //0: 名詞, 1: 動詞, 2: 形容詞, 3: 副詞, 4: 助動詞, 5: 代名詞, 6: 前置詞, 7: 冠詞, 8: 接続詞
    @objc dynamic var type: Int = 0
    
    convenience init(meaning: String, type: Int) {
        self.init()
        self.meaning = meaning
        self.type = type
    }
}

class Word: Object {
    @objc dynamic var wordID = UUID().uuidString
    @objc dynamic var word: String = ""
    var meanings = List<Meaning>()
    
    let sets = List<WordSet>()
    
    let wordAnsHistory = LinkingObjects(fromType: WordAnsHistory.self, property: "word")
    var correctAnsRate = List<WordAnsHistory>()
    
    convenience init(word: String, meanings: [Meaning]) {
        self.init()
        self.word = word
        for meaning in meanings {
            self.meanings.append(meaning)
        }
    }
    
    override static func primaryKey() -> String? {
        return "wordID"
    }
}

class WordSet: Object {
    @objc dynamic var setID = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var color: Int = 0
    @objc dynamic var emoji: String = ""
    
    let word = LinkingObjects(fromType: Word.self, property: "sets")
    var words = List<Word>()
    
    let setAnsHistory = LinkingObjects(fromType: SetAnsHistory.self, property: "set")
    var correctAnsRate = List<SetAnsHistory>()
    
    convenience init(title: String, color: Int, emoji: String) {
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
    
    let set = List<WordSet>()
    
    convenience init(date: Date, rate: Double) {
        self.init()
        self.date = date
        self.rate = rate
    }
    
    override static func primaryKey() -> String? {
        return "setAnsHistoryID"
    }
}

