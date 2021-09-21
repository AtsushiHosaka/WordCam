//
//  QuizSystem.swift
//  QuizSystem
//
//  Created by 保坂篤志 on 2021/09/21.
//

import Foundation

struct Quiz {
    
    var word = Word()
    var correctAnsNum: Int = 0
    var choices = [String]()
    
}

struct QuizSystem {
    
    static let shared = QuizSystem()
    
    func setupQuiz(words: [Word]) -> [Quiz] {
        var words = words
        words.shuffle()
        
        var dummyMeanings = Array(RealmService.shared.realm.objects(Meaning.self))
        dummyMeanings += defaultDummyModel
        
        var quizArray = [Quiz]()
        
        for word in words {
            var quiz = Quiz()
            
            quiz.word = word
            
            let correctAnsNum = Int.random(in: 0...3)
            quiz.correctAnsNum = correctAnsNum
            
            var choices = ["", "", "", ""]
            choices[correctAnsNum] = word.meanings[0].meaning
            
            for i in 0...3 {
                if i != correctAnsNum {
                    var dummy = dummyMeanings
                    var n = Int.random(in: 0..<dummy.count)
                    
                    while dummy[n].meaning == word.meanings[0].meaning ||
                          choices.contains(dummy[n].meaning) ||
                          word.meanings[0].type * word.meanings[0].type != word.meanings[0].type * dummy[n].type ||
                          Array(word.meanings).contains(dummy[n]) {
                        n = Int.random(in: 0..<dummy.count)
                    }
                    choices[i] = dummy[n].meaning
                    dummy.remove(at: n)
                }
            }
            
            quiz.choices = choices
            quizArray.append(quiz)
        }
        return quizArray
    }
    
    let defaultDummyModel = [Meaning(meaning: "方法", type: 1),
                             Meaning(meaning: "乗客", type: 1),
                             Meaning(meaning: "材料", type: 1),
                             Meaning(meaning: "成分", type: 1),
                             Meaning(meaning: "〜を防ぐ", type: 2),
                             Meaning(meaning: "〜を用意する", type: 2),
                             Meaning(meaning: "〜を与える", type: 2),
                             Meaning(meaning: "〜を選ぶ", type: 2),
                             Meaning(meaning: "以前の", type: 3),
                             Meaning(meaning: "最近の", type: 3),
                             Meaning(meaning: "特定の", type: 3),
                             Meaning(meaning: "あいまいな", type: 3),
                             Meaning(meaning: "ますます", type: 4),
                             Meaning(meaning: "確かに", type: 4),
                             Meaning(meaning: "正確に", type: 4),
                             Meaning(meaning: "思いがけなく", type: 4),
                             Meaning(meaning: "できる", type: 5),
                             Meaning(meaning: "かもしれない", type: 5),
                             Meaning(meaning: "に違いない", type: 5),
                             Meaning(meaning: "するだろう", type: 5),
                             Meaning(meaning: "わたしは", type: 6),
                             Meaning(meaning: "あなたの", type: 6),
                             Meaning(meaning: "それを", type: 6),
                             Meaning(meaning: "私たち自身", type: 6),
                             Meaning(meaning: "〜までずっと", type: 7),
                             Meaning(meaning: "〜を横切って", type: 7),
                             Meaning(meaning: "〜のあちこちに", type: 7),
                             Meaning(meaning: "〜について", type: 7),
                             Meaning(meaning: "その", type: 8),
                             Meaning(meaning: "例の", type: 8),
                             Meaning(meaning: "あるひとつの", type: 8),
                             Meaning(meaning: "〜する間に", type: 9),
                             Meaning(meaning: "そして", type: 9),
                             Meaning(meaning: "または", type: 9),
                             Meaning(meaning: "だから", type: 9)]
}
