//
//  WordsModel.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/16.
//

import Foundation
import NaturalLanguage
import RealmSwift


class Meaning: Object {
    @objc dynamic var meaning: String = ""
    //1: 名詞, 2: 動詞, 3: 形容詞, 4: 副詞, 5: 助動詞, 6: 代名詞, 7: 前置詞, 8: 冠詞, 9: 接続詞
    @objc dynamic var type: Int = 0
    @objc dynamic var parentWord: String = ""
    
    convenience init(meaning: String, type: Int, parentWord: String) {
        self.init()
        self.meaning = meaning
        self.type = type
        self.parentWord = parentWord
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Meaning else { return false }
        return self.meaning == object.meaning
    }
}

class Word: Object {
    @objc dynamic var wordID = UUID().uuidString
    @objc dynamic var word: String = ""
    @objc dynamic var correctAnsRateAverage: Double = 0
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
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Word else { return false }
        return self.word == object.word
    }
}

class WordSet: Object {
    @objc dynamic var setID = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var color: Int = 0
    @objc dynamic var emoji: String = ""
    @objc dynamic var isShared: Bool = false
    @objc dynamic var isOriginal: Bool = false
    @objc dynamic var correctAnsRateAverage: Double = 0
    
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
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? WordSet else { return false }
        return self.setID == object.setID
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

