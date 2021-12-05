//
//  FirebaseAPI.swift
//  FirebaseAPI
//
//  Created by 保坂篤志 on 2021/10/06.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

struct FirebaseAPI {
    
    static let shared = FirebaseAPI()
    
    private var ref = Database.database().reference()
    
    func addOriginalSetToFirebase(ID: String, set: WordSet) {
        ref.child("original").child(ID).updateChildValues(["title": set.title,
                                                         "color": set.color,
                                                         "emoji": set.emoji,
                                                         "favorite": 0])
        
        for word in Array(set.words) {
            ref.child("original").child(ID).child("words").childByAutoId().updateChildValues(
                ["word": word.word,
                 "meaning": ["meaning": word.meanings[0].meaning,
                             "type": word.meanings[0].type,
                             "parentWord": word.meanings[0].parentWord]])
        }
    }
    
    func readSetFromFirebase(path: String, completionHandler: @escaping (Any?) -> Void) {
        ref.child(path).observeSingleEvent(of: .value) { Snapshot in
            if let data = Snapshot.value{
                completionHandler(data)
            }else{
                completionHandler("error")
            }
        }
    }
    
    func addFavorite(path: String, ID: String) {
        ref.child(path).child(ID).child("favorite").observeSingleEvent(of: .value) { (Snapshot) in
            if let data = Snapshot.value {
                let data = Int(JSON(data).rawString() ?? "0") ?? 0
                ref.child(path).child(ID).updateChildValues(["favorite": data + 1])
            }else{
                print("error")
            }
        }
    }
}
