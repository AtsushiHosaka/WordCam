//
//  RealmServices.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/07/25.
//

import Foundation
import RealmSwift

class RealmService {

    private init() {}
    static let shared = RealmService()
    var realm = try! Realm()
    
    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            post(error)
        }
    }
    
    func update<T: Object>(_ object: T, with dictionary: [String:Any]) {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            post(error)
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            post(error)
        }
    }
    
    func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        }catch {
            post(error)
        }
    }
    
    
    func post(_ error: Error) {
        NotificationCenter.default.post(name: NSNotification.Name("RealmError"), object: error)
    }
    
    func createWord(wordValue: String, meaningsValue: [String], typesValue: [Int]) -> Word {
        var meanings = [Meaning]()
        for i in 0..<meaningsValue.count {
            let meaning = Meaning(meaning: meaningsValue[i], type: typesValue[i], parentWord: wordValue)
            meanings.append(meaning)
        }
        
        let word = Word(word: wordValue, meanings: meanings)
        
        return word
    }
    
    func addWordsToSet(setID: String, words: [Word]) {
        guard let set = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID) else { return }
        var currentWords = Array(set.words)
        
        for word in words {
            currentWords.append(word)
        }
        
        RealmService.shared.update(set, with: ["words": currentWords])
    }
}
