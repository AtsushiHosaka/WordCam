//
//  QuizSystem.swift
//  QuizSystem
//
//  Created by 保坂篤志 on 2021/09/21.
//

import Foundation
import NaturalLanguage

struct Quiz {
    
    var word = Word()
    var question: String = ""
    var correctAnsNum: Int = 0
    var choices = [String]()
    
}

struct QuizSystem {
    
    static let shared = QuizSystem()
    
    func setupQuizEtoJ(words: [Word]) -> [Quiz] {
        var words = words
        words.shuffle()
        
        var dummyMeanings = Array(RealmService.shared.realm.objects(Meaning.self))
        dummyMeanings += defaultDummyMeanings
        
        var quizArray = [Quiz]()
        
        for word in words {
            var quiz = Quiz()
            
            quiz.word = word
            quiz.question = word.word
            
            let correctAnsNum = Int.random(in: 0...3)
            quiz.correctAnsNum = correctAnsNum
            let answer = word.meanings[0]
            
            var choices = ["", "", "", ""]
            choices[correctAnsNum] = answer.meaning
            
            var dummy = dummyMeanings
            let embedding = NLEmbedding.wordEmbedding(for: .english)!
            dummy.sort(by: {embedding.distance(between: $0.parentWord, and: word.word) < embedding.distance(between: $1.parentWord, and: word.word)})
            var dummyChoices = [String]()
            
            for _ in 0..<3 {
                for meaning in dummy {
                    if meaning.meaning != answer.meaning &&
                        !dummyChoices.contains(meaning.meaning) &&
                        answer.type * answer.type == answer.type * meaning.type &&
                        !Array(word.meanings).contains(meaning) {
                        
                        dummyChoices.append(meaning.meaning)
                        dummy.removeFirst()
                        break
                    }else {
                        dummy.removeFirst()
                    }
                }
            }
            
            dummyChoices.shuffle()
            
            for i in 0...3 {
                if i != correctAnsNum {
                    choices[i] = dummyChoices.first ?? ""
                    dummyChoices.removeFirst()
                }
            }
            
            quiz.choices = choices
            quizArray.append(quiz)
        }
        return quizArray
    }
    
    func setupQuizJtoE(words: [Word]) -> [Quiz] {
        var words = words
        words.shuffle()
        
        var dummyWords = Array(RealmService.shared.realm.objects(Word.self))
        dummyWords += defaultDummyWords
        
        var quizArray = [Quiz]()
        
        for word in words {
            var quiz = Quiz()
            
            quiz.word = word
            quiz.question = word.meanings[0].meaning
            
            let correctAnsNum = Int.random(in: 0...3)
            quiz.correctAnsNum = correctAnsNum
            let answer = word.word
            
            var choices = ["", "", "", ""]
            choices[correctAnsNum] = answer
            
            var dummy = dummyWords
            dummy.sort(by: {minDistance($0.word, answer) < minDistance($1.word, answer)})
            var dummyChoices = [String]()
            
            for _ in 0..<3 {
                for dummyWord in dummy {
                    if dummyWord.word != answer &&
                        !dummyChoices.contains(dummyWord.word) &&
                        dummyWord.word != word.meanings[0].parentWord {
                        
                        dummyChoices.append(dummyWord.word)
                        dummy.removeFirst()
                        break
                    }else {
                        dummy.removeFirst()
                    }
                }
            }
            
            dummyChoices.shuffle()
            
            for i in 0...3 {
                if i != correctAnsNum {
                    choices[i] = dummyChoices.first ?? ""
                    dummyChoices.removeFirst()
                }
            }
            
            quiz.choices = choices
            quizArray.append(quiz)
        }
        return quizArray
    }
    
    func minDistance(_ word1: String, _ word2: String) -> Int {
        let w1 = word1.map({ String($0) })
        let w2 = word2.map({ String($0) })
        var dp = [[Int]](repeating: [Int](repeating: Int.max, count: w2.count+1), count: w1.count+1)
        dp[0][0] = 0
        
        for i in 0..<w1.count+1 {
            for j in 0..<w2.count+1 {
                if i-1 >= 0 && j-1 >= 0 {
                    
                    if w1[i-1] == w2[j-1] {
                        dp[i][j] = min(dp[i][j], dp[i-1][j-1])
                    }
                    
                    else {
                        dp[i][j] = min(dp[i][j], dp[i-1][j-1]+1)
                    }
                }
                
                if i-1 >= 0 {
                    dp[i][j] = min(dp[i][j], dp[i-1][j]+1)
                }
                
                if j-1 >= 0 {
                    dp[i][j] = min(dp[i][j], dp[i][j-1]+1)
                }
            }
        }
        
        return dp[w1.count][w2.count]
    }
    
    let defaultDummyMeanings = [Meaning(meaning: "方法", type: 1, parentWord: "method"),
                             Meaning(meaning: "乗客", type: 1, parentWord: "passenger"),
                             Meaning(meaning: "材料", type: 1, parentWord: "stuff"),
                             Meaning(meaning: "成分", type: 1, parentWord: "component"),
                             Meaning(meaning: "〜を防ぐ", type: 2, parentWord: "prevent"),
                             Meaning(meaning: "〜を用意する", type: 2, parentWord: "prepare"),
                             Meaning(meaning: "〜を与える", type: 2, parentWord: "give"),
                             Meaning(meaning: "〜を選ぶ", type: 2, parentWord: "choose"),
                             Meaning(meaning: "以前の", type: 3, parentWord: "previous"),
                             Meaning(meaning: "最近の", type: 3, parentWord: "recent"),
                             Meaning(meaning: "特定の", type: 3, parentWord: "specific"),
                             Meaning(meaning: "あいまいな", type: 3, parentWord: "vague"),
                             Meaning(meaning: "ますます", type: 4, parentWord: "increasingly"),
                             Meaning(meaning: "確かに", type: 4, parentWord: "surely"),
                             Meaning(meaning: "正確に", type: 4, parentWord: "exactly"),
                             Meaning(meaning: "思いがけなく", type: 4, parentWord: "unexpectedly"),
                             Meaning(meaning: "できる", type: 5, parentWord: "can"),
                             Meaning(meaning: "かもしれない", type: 5, parentWord: "may"),
                             Meaning(meaning: "に違いない", type: 5, parentWord: "must"),
                             Meaning(meaning: "するだろう", type: 5, parentWord: "will"),
                             Meaning(meaning: "わたしは", type: 6, parentWord: "I"),
                             Meaning(meaning: "あなたの", type: 6, parentWord: "your"),
                             Meaning(meaning: "それを", type: 6, parentWord: "its"),
                             Meaning(meaning: "私たち自身", type: 6, parentWord: "own"),
                             Meaning(meaning: "〜までずっと", type: 7, parentWord: "until"),
                             Meaning(meaning: "〜を横切って", type: 7, parentWord: "across"),
                             Meaning(meaning: "〜のあちこちに", type: 7, parentWord: "around"),
                             Meaning(meaning: "〜について", type: 7, parentWord: "about"),
                             Meaning(meaning: "その", type: 8, parentWord: "the"),
                             Meaning(meaning: "例の", type: 8, parentWord: "the"),
                             Meaning(meaning: "あるひとつの", type: 8, parentWord: "a"),
                             Meaning(meaning: "〜する間に", type: 9, parentWord: "while"),
                             Meaning(meaning: "そして", type: 9, parentWord: "and"),
                             Meaning(meaning: "または", type: 9, parentWord: "or"),
                             Meaning(meaning: "だから", type: 9, parentWord: "so")]
    
    let defaultDummyWords = [Word(word: "give", meanings: [Meaning(meaning: "〜を与える",type: 2, parentWord: "give")]),
                             Word(word: "component", meanings: [Meaning(meaning: "成分", type: 1, parentWord: "component")]),
                             Word(word: "own", meanings: [Meaning(meaning: "私たち自身", type: 6, parentWord: "own")]),
                             Word(word: "about", meanings: [Meaning(meaning: "〜について", type: 7, parentWord: "about")])]
}
