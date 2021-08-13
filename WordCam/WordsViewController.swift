//
//  WordsTableViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/27.
//

import UIKit
import RealmSwift

class WordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = RealmService.shared.realm
    var data: Results<Word>?
    var words = [String]()
    var selectedNum: Int?
    @IBOutlet var wordsTableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
        
        self.navigationController?.navigationBar.sizeToFit()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        data = realm.objects(Word.self)
        
        if data?.count == 0 {
            wordsTableView.isHidden = true
            alertLabel.isHidden = false
        }else {
            wordsTableView.isHidden = false
            alertLabel.isHidden = true
        }
        
        wordsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    //cellとかの背景色考えた方が良さそう
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data?[indexPath.row].word
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNum = indexPath.row
        performSegue(withIdentifier: "toWordView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWordView" {
            let wordView: WordViewController = segue.destination as! WordViewController
            wordView.word = self.data?[selectedNum ?? 0]
        }
    }
    
    func toAddWordView() {
        performSegue(withIdentifier: "toAddWordView", sender: nil)
    }
    
    @IBAction func addButtonPressed() {
        let alertSheet = UIAlertController(title: "単語を登録", message: "単語の登録方法を選択してください", preferredStyle: UIAlertController.Style.actionSheet)
        let action1 = UIAlertAction(title: "単語を入力する", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toAddWordView", sender: nil)
        })
        let action2 = UIAlertAction(title: "写真から登録する", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            print("sita")
        })
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler: {(action: UIAlertAction!) -> Void in
            print("can")
        })
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true, completion: nil)
    }
}


