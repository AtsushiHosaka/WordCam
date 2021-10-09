//
//  SetSearcher.swift
//  SetSearcher
//
//  Created by 保坂篤志 on 2021/10/06.
//

import Foundation
import SwiftyJSON

struct SetSearcher {
    static let shared = SetSearcher()
    
    func readSetData(path: String, ID: String?, completionHandler: @escaping ([WordSet]) -> Void) {
        let key = path + "/" + (ID ?? "")
        FirebaseAPI.shared.readSetFromFirebase(path: key, completionHandler: { data in
            if data is NSNull {
                print("error")
            }else {
                if path == "default" {
                    let parsedData = parseSetsData(data: JSON(data!))
                    completionHandler(parsedData)
                }else {
                    let parsedData = parseSetData(ID: ID ?? "", data: JSON(data!))
                    completionHandler([parsedData])
                }
            }
        })
    }
    
    func parseSetsData(data: JSON) -> [WordSet] {
        var parsedSetsData = [(set: WordSet, favor: Int)]()
        let keys = data.dictionary!.keys
        
        for key in keys.enumerated() {
            let wordSet = parseSetData(ID: key.element, data: data[key.element])
            let favor = Int(data[key.element]["favorite"].rawString() ?? "0") ?? 0
            
            parsedSetsData.append((wordSet, favor))
        }
        
        parsedSetsData.sort(by: { $0.favor > $1.favor })
        
        var parsedData = [WordSet]()
        for parsedSetData in parsedSetsData {
            parsedData.append(parsedSetData.set)
        }
        
        return parsedData
    }
    
    func parseSetData(ID: String, data: JSON) -> WordSet {
        let title = data["title"].rawString() ?? ""
        let color = Int(data["color"].rawString() ?? "0") ?? 0
        let emoji = data["emoji"].rawString() ?? "🤯"
        let words = parseWordsData(data: data["words"])
        
        let wordSet = WordSet(title: title, color: color, emoji: emoji)
        wordSet.setID = ID
        for word in words {
            wordSet.words.append(word)
        }
        
        return wordSet
    }
    
    func parseWordsData(data: JSON) -> [Word] {
        var parsedWordsData = [Word]()
        let keys = data.dictionary!.keys
        
        for key in keys.enumerated() {
            let word = data[key.element]["word"].rawString() ?? ""
            let meaning = parseMeaningData(data: data[key.element]["meaning"])
            
            parsedWordsData.append(Word(word: word, meanings: [meaning]))
        }
        
        return parsedWordsData
    }
    
    func parseMeaningData(data: JSON) -> Meaning {
        let meaning = data["meaning"].rawString() ?? ""
        let type = Int(data["type"].rawString() ?? "0") ?? 0
        let parentWord = data["parentWord"].rawString() ?? ""
        
        return Meaning(meaning: meaning, type: type, parentWord: parentWord)
    }
}
