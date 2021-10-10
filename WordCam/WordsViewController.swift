//
//  WordsTableViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/27.
//

import UIKit
import RealmSwift
import CircleMenu

class WordsViewController: UIViewController {
    
    let menuItems: [(icon: String, color: UIColor)] = [
        ("pencil", MyColor.shared.mainColor),
        ("", UIColor.clear),
        ("", UIColor.clear),
        ("camera.fill", MyColor.shared.mainColor)
    ]
    var searchController = UISearchController(searchResultsController: nil)
    var data = [Word]()
    var searchResults = [Word]()
    var isEditMode: Bool = false
    var selectedNum: Int?
    var sortType: Int = 0
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var editBarButton: UIBarButtonItem!
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    @IBOutlet var addWordMenu: CircleMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupSearchController()
        setupTableView()
        setupMenu()
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
        searchController.searchBar.backgroundColor = MyColor.shared.backgroundColor
        searchController.searchBar.barTintColor = MyColor.shared.backgroundColor
        
        navigationItem.searchController = searchController
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = isEditMode
        tableView.separatorColor = UIColor.systemGray3
    }
    
    func setupMenu() {
        addWordMenu.delegate = self
        addWordMenu.backgroundColor = MyColor.shared.mainColor
        addWordMenu.tintColor = UIColor.white
        addWordMenu.setTitle("", for: .normal)
        let normalConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let selectedConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large)
        let normalImage = UIImage(systemName: "plus", withConfiguration: normalConfig)
        let selectedImage = UIImage(systemName: "xmark", withConfiguration: selectedConfig)
        addWordMenu.setImage(normalImage, for: .normal)
        addWordMenu.setImage(selectedImage, for: .selected)
        addWordMenu.layer.cornerRadius = addWordMenu.bounds.height / 2
    }
    
    func reloadNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if isEditMode {
            editBarButton.title = "削除"
            cancelBarButton.isEnabled = true
            cancelBarButton.tintColor = MyColor.shared.mainColor
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
        let words = RealmService.shared.realm.objects(Word.self)
        
        if words.count == 0 {
            tableView.isHidden = true
            alertLabel.isHidden = false
        }else {
            tableView.isHidden = false
            alertLabel.isHidden = true
            
            data = Array(words)
            sortData()
        }
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
    
    func showErrorAlert() {
        let alert = MyAlert.shared.errorAlert(message: "単語を選択してください")
        present(alert, animated: true, completion: nil)
    }
    
    func showDeleteAlert(indexPaths: [IndexPath]) {
        let action = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.deleteWord(indexPaths: indexPaths)
            self.isEditMode = false
            self.reloadNavigationController()
            self.reloadTableView()
        })
        let alert = MyAlert.shared.customAlert(title: "単語を削除しますか？", message: "", style: .alert, action: [action])
        present(alert, animated: true, completion: nil)
    }
    
    func deleteWord(indexPaths: [IndexPath]) {
        let num = data.count
        for indexPath in indexPaths {
            let word = data[indexPath.row]
            
            for meaning in Array(word.meanings) {
                RealmService.shared.delete(meaning)
            }
            
            for history in Array(word.correctAnsRate) {
                RealmService.shared.delete(history)
            }
            RealmService.shared.delete(word)
        }
        
        if num == indexPaths.count {
            data = []
        }
        
        reloadData()
    }
    
    func sortData() {
        data.sort(by: { $0.word < $1.word })
        if sortType == 1 {
            data.sort(by: { $0.correctAnsRateAverage < $1.correctAnsRateAverage })
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWordView" {
            let wordView: WordViewController = segue.destination as! WordViewController
            if searchController.searchBar.text == "" {
                wordView.word = self.data[selectedNum ?? 0]
            }else {
                wordView.word = self.searchResults[selectedNum ?? 0]
            }
            wordView.isEditable = true
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

extension WordsViewController: CircleMenuDelegate {
    
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.tintColor = UIColor.white
        button.backgroundColor = menuItems[atIndex].color
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: menuItems[atIndex].icon, withConfiguration: configuration), for: .normal)
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        addWordMenu.isSelected = false
        if atIndex == 0 {
            performSegue(withIdentifier: "toAddWordView", sender: nil)
        }else if atIndex == 3 {
            performSegue(withIdentifier: "toAddWordsByCameraView", sender: nil)
        }
    }
}
