//
//  SelectWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/08.
//

import UIKit
import RealmSwift

class SelectSetWordViewController: UIViewController {
    
    var setID: String?
    let realm = RealmService.shared.realm
    var data: Results<Word>?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadNavigationController()
        reloadData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupNavigationController() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func reloadData() {
        data = realm.objects(Word.self)
        setID = UserDefaults.standard.string(forKey: "setID")
        if data?.count == 0 {
            tableView.isHidden = true
            alertLabel.isHidden = false
        }else {
            tableView.isHidden = false
            alertLabel.isHidden = true
        }
        
        tableView.reloadData()
    }
    
    func showUnableAlert(word: String) {
        let alert = UIAlertController(title: "エラー", message: "すでに'\(word)'は追加されています", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension SelectSetWordViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data?[indexPath.row].word
        return cell
    }
}

extension SelectSetWordViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedWord = data?[indexPath.row] else { return }
        guard let set = realm.object(ofType: Sets.self, forPrimaryKey: setID)  else { return }
        var words = Array(set.words)
        if !words.contains(selectedWord) {
            words.append(selectedWord)
        }else {
            tableView.deselectRow(at: indexPath, animated: true)
            showUnableAlert(word: selectedWord.word)
        }
        
        RealmService.shared.update(set, with: ["words": words])
        self.navigationController?.popViewController(animated: true)
    }
}
