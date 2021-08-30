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
    var searchController = UISearchController(searchResultsController: nil)
    var data = [Word]()
    var searchResults = [Word]()
    var isEditMode: Bool = false
    var selectedNum: Int?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var editBarButton: UIBarButtonItem!
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupSearchController()
        setupTableView()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadNavigationController()
        reloadData()
    }
    
    func setupNavigationController() {
        navigationController?.navigationBar.sizeToFit()
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
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = isEditMode
        tableView.separatorColor = UIColor.systemGray3
    }
    
    func setupButton() {
        addButton.layer.cornerRadius = addButton.bounds.height / 2
    }
    
    func reloadNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if isEditMode {
            editBarButton.title = "削除"
            cancelBarButton.isEnabled = true
            cancelBarButton.tintColor = Color.shared.mainColor
        }else {
            editBarButton.title = "編集"
            cancelBarButton.isEnabled = false
            cancelBarButton.tintColor = UIColor.clear
        }
    }
    
    func reloadTableView() {
        tableView.isEditing = isEditMode
    }
    
    func reloadData() {
        let words = realm.objects(Word.self)
        
        if words.count == 0 {
            tableView.isHidden = true
            alertLabel.isHidden = false
        }else {
            tableView.isHidden = false
            alertLabel.isHidden = true
            
            data = Array(words).sorted(by: {$0.word < $1.word})
            
            tableView.reloadData()
        }
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
    
    @IBAction func editButtonPressed() {
        if isEditMode == true {
            if tableView.indexPathsForSelectedRows?.count == 0 || tableView.indexPathsForSelectedRows == nil {
                showErrorAlert()
            }else {
                showDeleteAlert(indexPaths: tableView.indexPathsForSelectedRows!)
            }
        }else {
            isEditMode = true
            reloadNavigationController()
            reloadTableView()
        }
    }
    
    @IBAction func cancelButtonPressed() {
        isEditMode = false
        reloadNavigationController()
        reloadTableView()
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "エラー", message: "単語を選択してください", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showDeleteAlert(indexPaths: [IndexPath]) {
        let alert = UIAlertController(title: "単語を削除しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.deleteWord(indexPaths: indexPaths)
            self.isEditMode = false
            self.reloadNavigationController()
            self.reloadTableView()
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteWord(indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let word = data[indexPath.row]
            RealmService.shared.delete(word)
        }
        
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWordView" {
            let wordView: WordViewController = segue.destination as! WordViewController
            wordView.word = self.data[selectedNum ?? 0]
        }
    }
}

extension WordsViewController: UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var initialArray = [String]()
        for word in data {
            initialArray.append(String(word.word[word.word.startIndex]))
        }
        let initialSet = Set(initialArray)
        initialArray = Array(initialSet)
        initialArray.sort()
        return initialArray
    }
        
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        self.tableView.scrollToRow(at: [0, index], at: .top, animated: true)
        return index
    }
}

extension WordsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditMode == false {
            selectedNum = indexPath.row
            performSegue(withIdentifier: "toWordView", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            showDeleteAlert(indexPaths: [indexPath])
        }
    }
}

extension WordsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchResults = data.filter { word in
            return word.word.contains(searchController.searchBar.text!)
        }
        
        tableView.reloadData()
    }
    
    
}
