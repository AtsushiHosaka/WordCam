//
//  SelectWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/08.
//

import UIKit

class SelectSetWordViewController: UIViewController {
    
    let realm = RealmService.shared.realm
    var searchController = UISearchController(searchResultsController: nil)
    var setID: String?
    var set = Sets()
    var data = [Word]()
    var searchResults = [Word]()
    var isSelected = [Bool]()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationController()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadNavigationController()
        reloadData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
    }
    
    func setupNavigationController() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = Color.shared.backgroundColor
        searchController.searchBar.barTintColor = Color.shared.backgroundColor
        
        navigationItem.searchController = searchController
    }
    
    func reloadNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func reloadData() {
        let allWords = realm.objects(Word.self)
        setID = UserDefaults.standard.string(forKey: "setID")
        set = realm.object(ofType: Sets.self, forPrimaryKey: setID) ?? Sets()
        data = []
        
        if allWords.count == 0 {
            tableView.isHidden = true
            addButton.isEnabled = false
            addButton.tintColor = UIColor.clear
            alertLabel.isHidden = false
        }else {
            tableView.isHidden = false
            addButton.isEnabled = true
            addButton.tintColor = Color.shared.mainColor
            alertLabel.isHidden = true
        }
        
        let words = Array(set.words)
        for word in allWords {
            if !words.contains(word) {
                data.append(word)
            }
        }
        
        data.sort(by: {$0.word < $1.word})
        isSelected = [Bool](repeating: false, count: data.count)
        tableView.reloadData()
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "エラー", message: "単語を選択してください", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showUnableAlert(word: String) {
        let alert = UIAlertController(title: "エラー", message: "すでに'\(word)'は追加されています", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed() {
        if !isSelected.contains(true) {
            showErrorAlert()
            return
        }
        
        var words = Array(set.words)
        for i in 0..<data.count {
            if isSelected[i] {
                words.append(data[i])
            }
        }
        
        guard let set = realm.object(ofType: Sets.self, forPrimaryKey: setID)  else { return }
        RealmService.shared.update(set, with: ["words": words])
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectSetWordViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text == "" {
            return data.count
        }else {
            return searchResults.count
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if searchController.searchBar.text == "" {
            cell.textLabel?.text = data[indexPath.row].word
        }else {
            cell.textLabel?.text = searchResults[indexPath.row].word
        }
        return cell
    }
}

extension SelectSetWordViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isSelected[indexPath.row] = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        isSelected[indexPath.row] = false
    }
}

extension SelectSetWordViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        searchResults = data.filter { word in
            return word.word.contains(searchController.searchBar.text!)
        }

        tableView.reloadData()
    }
}
