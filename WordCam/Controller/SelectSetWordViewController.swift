//
//  SelectWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/08.
//

import UIKit
import RealmSwift

class SelectSetWordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var setID: String?
    let realm = RealmService.shared.realm
    var data: Results<Word>?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        data = realm.objects(Word.self)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data?[indexPath.row].word
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedWord = data?[indexPath.row] else {return}
        guard let set = realm.object(ofType: Sets.self, forPrimaryKey: setID)  else { return }
        var words = Array(set.words)
        words.append(selectedWord)
        
        RealmService.shared.update(set, with: ["words": words])
        self.navigationController?.popViewController(animated: true)
    }
}
