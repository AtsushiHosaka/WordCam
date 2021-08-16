//
//  WordsTableViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/27.
//

import UIKit
import RealmSwift

class WordsViewController: UIViewController {
    
    let realm = RealmService.shared.realm
    var data: Results<Word>?
    var words = [String]()
    var selectedNum: Int?
    @IBOutlet var wordsTableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupTableView()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadNavigationController()
        reloadData()
    }
    
    func setupNavigationController() {
        self.navigationController?.navigationBar.sizeToFit()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupTableView() {
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
    }
    
    func setupButton() {
        addButton.layer.cornerRadius = addButton.bounds.height / 2
    }
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func reloadData() {
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
    
    @IBAction func addButtonPressed() {
        let alertSheet = UIAlertController(title: "単語を登録", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let action1 = UIAlertAction(title: "単語を入力する", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toAddWordView", sender: nil)
        })
        let action2 = UIAlertAction(title: "写真から登録する", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toAddWordsByCameraView", sender: nil)
        })
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWordView" {
            let wordView: WordViewController = segue.destination as! WordViewController
            wordView.word = self.data?[selectedNum ?? 0]
        }
    }
}

extension WordsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data?[indexPath.row].word
        return cell
    }
}

extension WordsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNum = indexPath.row
        performSegue(withIdentifier: "toWordView", sender: nil)
    }
}
