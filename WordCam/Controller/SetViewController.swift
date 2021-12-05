//
//  SetViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit
import Charts
import CircleMenu

class SetViewController: UIViewController {
    
    let menuItems: [(icon: String, color: UIColor)] = [
        ("folder.fill", MyColor.shared.mainColor),
        ("", UIColor.clear),
        ("", UIColor.clear),
        ("camera.fill", MyColor.shared.mainColor)
    ]
    var searchController = UISearchController(searchResultsController: nil)
    var set = WordSet()
    var searchResults = [Word]()
    var selectedWord = Word()
    var setID: String = ""
    var isHistoryNil: Bool?
    var quizType: Int = 0
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var addWordMenu: CircleMenu!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupSearchController()
        setupTableView()
        setupButton()
        setupMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadNavigationController()
        reloadTabBarController()
        reloadData()
    }
    
    func setupNavigationController() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.sizeToFit()
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
        
        tableView.register(UINib(nibName: "SetChartCell", bundle: nil), forCellReuseIdentifier: "SetChartCell")
    }
    
    func setupButton() {
        startButton.layer.cornerRadius = startButton.bounds.height / 2
        startButton.layer.cornerCurve = .continuous
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
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func reloadTabBarController() {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func reloadData() {
        setID = UserDefaults.standard.string(forKey: "setID") ?? ""
        set = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID) ?? WordSet()
        self.title = set.title
        
        if set.words.count == 0 {
            tableView.isHidden = true
            startButton.isHidden = true
            alertLabel.isHidden = false
        }else {
            tableView.isHidden = false
            startButton.isHidden = false
            alertLabel.isHidden = true
        }
        
        let words = Array(set.words).sorted(by: {$0.word < $1.word})
        let sortedSet = WordSet(title: set.title, color: set.color, emoji: set.emoji)
        sortedSet.correctAnsRate = set.correctAnsRate
        sortedSet.words.append(objectsIn: words)
        
        sortedSet.isShared = set.isShared
        sortedSet.isOriginal = set.isOriginal
        sortedSet.setID = setID
        
        set = sortedSet
        
        if set.correctAnsRate.count == 0 {
            isHistoryNil = true
        }else {
            isHistoryNil = false
        }
        
        tableView.reloadData()
    }
    
    @IBAction func startButtonPressed() {
        let action1 = UIAlertAction(title: "英→和", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.quizType = 0
            self.performSegue(withIdentifier: "toQuizView", sender: nil)
        })
        let action2 = UIAlertAction(title: "和→英", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.quizType = 1
            self.performSegue(withIdentifier: "toQuizView", sender: nil)
        })
        let alert = MyAlert.shared.customAlert(title: "モードを選択してください", message: "", style: .actionSheet, action: [action1, action2])
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonPressed() {
        if !set.isOriginal {
            showNotOriginalAlert()
        }else if setID == "auto" {
            showAutoSetAlert()
        }else if set.words.count > 10 {
            performSegue(withIdentifier: "toShareSetView", sender: nil)
        }else {
            showUnableToShareAlert()
        }
    }
    
    func showUnableToShareAlert() {
        let alert = MyAlert.shared.errorAlert(message: "単語を10個より多くしてください")
        present(alert, animated: true, completion: nil)
    }
    
    func showNotOriginalAlert() {
        let alert = MyAlert.shared.errorAlert(message: "ダウンロードしたセットは共有できません")
        present(alert, animated: true, completion: nil)
    }
    
    func showAutoSetAlert() {
        let alert = MyAlert.shared.errorAlert(message: "自動生成のセットは共有できません")
        present(alert, animated: true, completion: nil)
    }
    
    func deleteWord(indexPath: IndexPath) {
        var words = Array(set.words)
        words.remove(at: indexPath.row - 1)
        
        guard let editedSet = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID) else { return }
        RealmService.shared.update(editedSet, with: ["words": words])
        
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetWordView" {
            let wordView: WordViewController = segue.destination as! WordViewController
            wordView.word = selectedWord
            wordView.isEditable = false
        }else if segue.identifier == "toQuizView" {
            let quizView: QuizViewController = segue.destination as! QuizViewController
            quizView.type = quizType
        }else if segue.identifier == "toShareSetView" {
            let shareSetView: ShareSetViewController = segue.destination as! ShareSetViewController
            shareSetView.isShared = set.isShared
        }
    }
}

extension SetViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text == "" {
            return set.words.count + 1
        }else {
            return searchResults.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SetChartCell") as! SetChartCell
            cell.color = set.color
            cell.setData = Array(set.correctAnsRate)
            cell.backgroundColor = MyColor.shared.backgroundColor
            cell.isUserInteractionEnabled = false
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            if searchController.searchBar.text == "" {
                cell.textLabel?.text = set.words[indexPath.row - 1].word
            }else {
                cell.textLabel?.text = searchResults[indexPath.row - 1].word
            }
            cell.backgroundColor = MyColor.shared.backgroundColor
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if isHistoryNil == true {
                return 0
            }else {
                return 250
            }
        }else {
            return 50
        }
    }
}

extension SetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            return nil
        }else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.searchBar.text == "" {
            selectedWord = set.words[indexPath.row - 1]
        }else {
            selectedWord = searchResults[indexPath.row - 1]
        }
        performSegue(withIdentifier: "toSetWordView", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if indexPath.row == 0 {
            return false
        }else {
            return true
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
                self.deleteWord(indexPath: indexPath)
            })
            let alert = MyAlert.shared.customAlert(title: "削除", message: "この単語を削除しますか？", style: .alert, action: [action])
            present(alert, animated: true, completion: nil)
        }
    }

}

extension SetViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        searchResults = set.words.filter { word in
            return word.word.contains(searchController.searchBar.text!)
        }

        tableView.reloadData()
    }
}

extension SetViewController: CircleMenuDelegate {
    
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.tintColor = UIColor.white
        button.backgroundColor = menuItems[atIndex].color
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: menuItems[atIndex].icon, withConfiguration: configuration), for: .normal)
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        addWordMenu.isSelected = false
        if atIndex == 0 {
            performSegue(withIdentifier: "toSelectSetWordView", sender: nil)
        }else if atIndex == 3 {
            performSegue(withIdentifier: "toSelectWordByCameraView", sender: nil)
        }
    }
}
