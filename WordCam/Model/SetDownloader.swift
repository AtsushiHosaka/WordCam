//
//  SetDownloader.swift
//  SetDownloader
//
//  Created by 保坂篤志 on 2021/10/06.
//

import Foundation

struct SetDownloader {
    
    static let shared = SetDownloader()
    
    func addNewSet(setData: WordSet) {
        FirebaseAPI.shared.addFavorite(ID: setData.setID)
        
        let newSet = WordSet(title: setData.title, color: setData.color, emoji: setData.emoji)
        newSet.isOriginal = false
        RealmService.shared.create(newSet)
        
        let words = Array(RealmService.shared.realm.objects(Word.self))
        var setWords = [Word]()
        for word in Array(setData.words) {
            if words.contains(word) {
                let index = words.firstIndex(of: word)
                let currentWord = words[index!]
                var meanings = [Meaning]()
                
                for meaning in currentWord.meanings {
                    meanings.append(Meaning(meaning: meaning.meaning, type: meaning.type, parentWord: meaning.parentWord))
                    RealmService.shared.delete(meaning)
                }
                
                if meanings.contains(word.meanings[0]) {
                    let num = meanings.firstIndex(of: word.meanings[0])!
                    let mainMeaning = meanings[num]
                    meanings.remove(at: num)
                    meanings.insert(mainMeaning, at: 0)
                }else {
                    meanings.insert(word.meanings[0], at: 0)
                }
                RealmService.shared.update(currentWord, with: ["meanings": meanings])
                
                let newWord = RealmService.shared.realm.object(ofType: Word.self, forPrimaryKey: currentWord.wordID) ?? Word()
                setWords.append(newWord)
            }else {
                let newWord = Word(word: word.word, meanings: Array(word.meanings))
                RealmService.shared.create(newWord)
                setWords.append(newWord)
            }
        }
        
        RealmService.shared.addWordsToSet(setID: newSet.setID, words: setWords)
    }
}
