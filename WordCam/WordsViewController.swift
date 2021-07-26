//
//  WordsTableViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/27.
//

import UIKit
import RealmSwift

class WordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    let realm = try! Realm()
    var data: Results<Word>?
    var words = [String]()
    var selectedNum: Int?
    @IBOutlet var wordsTableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
        self.navigationController?.navigationBar.shadowImage = UIImage()
        reloading()
    }
    
    //追加画面はnavigationでの遷移だから、もしかしたら毎回呼び出されるかも。そうだったらwillappearへ
    func reloading() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        data = realm.objects(Word.self)
        print(data)
        
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
}
