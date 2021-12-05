//
//  SelectWordViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/08.
//

import UIKit

class SelectSetWordViewController: UIViewController {
    
    var searchController = UISearchController(searchResultsController: nil)
    var setID: String?
    var sortType: Int = 0
    var set = WordSet()
    var data = [Word]()
    var searchResults = [Word]()
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
        searchController.searchBar.backgroundColor = MyColor.shared.backgroundColor
        searchController.searchBar.barTintColor = MyColor.shared.backgroundColor
        
        navigationItem.searchController = searchController
    }
    
    func reloadNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func reloadData() {
        let allWords = RealmService.shared.realm.objects(Word.self)
        setID = UserDefaults.standard.string(forKey: "setID")
        set = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID) ?? WordSet()
        data = []
        
        if allWords.count == 0 {
            tableView.isHidden = true
            addButton.isEnabled = false
            addButton.tintColor = UIColor.clear
            alertLabel.isHidden = false
        }else {
            tableView.isHidden = false
            addButton.isEnabled = true
            addButton.tintColor = MyColor.shared.mainColor
            alertLabel.isHidden = true
        }
        
        let words = Array(set.words)
        for word in allWords {
            if !words.contains(word) {
                data.append(word)
            }
        }
        
        sortData()
    }
    
    func showErrorAlert(message: String) {
        let alert = MyAlert.shared.errorAlert(message: message)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed() {
        if tableView.indexPathsForSelectedRows == nil {
            showErrorAlert(message: "単語を選択してください")
            return
        }
        
        var words = [Word]()
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            words.append(data[indexPath.row])
        }
        
        RealmService.shared.addWordsToSet(setID: setID ?? "", words: words)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sortButtonPressed() {
        let action1 = UIAlertAction(title: "辞書順", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.sortType = 0
            self.sortData()
        })
        let action2 = UIAlertAction(title: "苦手順", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.sortType = 1
            self.sortData()
        })
        let alert = MyAlert.shared.customAlert(title: "並び替え", message: "", style: .actionSheet, action: [action1, action2])
        present(alert, animated: true, completion: nil)
    }
    
    func sortData() {
        data.sort(by: { $0.word < $1.word })
        if sortType == 1 {
            data.sort(by: { $0.correctAnsRateAverage < $1.correctAnsRateAverage })
        }
        tableView.reloadData()
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

extension SelectSetWordViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        searchResults = data.filter { word in
            return word.word.contains(searchController.searchBar.text!)
        }

        tableView.reloadData()
    }
}

extension SelectSetWordViewController: UITableViewDelegate {
    
}

extension SelectSetWordViewController: UIGestureRecognizerDelegate {
    
}
