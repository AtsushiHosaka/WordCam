//
//  SetViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit
import Charts

class SetViewController: UIViewController {
    
    let realm = RealmService.shared.realm
    var searchController = UISearchController(searchResultsController: nil)
    var set = Sets()
    var searchResults = [Word]()
    var selectedWord = Word()
    var setID: String?
    var isHistoryNil: Bool?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var addAlertButton: UIButton!
    @IBOutlet var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupSearchController()
        setupTableView()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadNavigationController()
        reloadTabBarController()
        reloadData()
    }
    
    func setupNavigationController() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
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
        
        tableView.register(UINib(nibName: "SetChartCell", bundle: nil), forCellReuseIdentifier: "SetChartCell")
    }
    
    func setupButton() {
        startButton.layer.cornerRadius = startButton.bounds.height / 2
        startButton.layer.cornerCurve = .continuous
    }
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func reloadTabBarController() {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func reloadData() {
        setID = UserDefaults.standard.string(forKey: "setID")
        set = realm.object(ofType: Sets.self, forPrimaryKey: setID!) ?? Sets()
        self.title = set.title
        
        if set.words.count == 0 {
            tableView.isHidden = true
            startButton.isHidden = true
            alertLabel.isHidden = false
            addAlertButton.isHidden = false
        }else {
            tableView.isHidden = false
            startButton.isHidden = false
            alertLabel.isHidden = true
            addAlertButton.isHidden = true
        }
        
        let words = Array(set.words).sorted(by: {$0.word < $1.word})
        let sortedSet = Sets(title: set.title, color: set.color, emoji: set.emoji)
        sortedSet.correctAnsRate = set.correctAnsRate
        sortedSet.words.append(objectsIn: words)
        set = sortedSet
        
        if set.correctAnsRate.count == 0 {
            isHistoryNil = true
        }else {
            isHistoryNil = false
        }
        
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed() {
        let alertSheet = UIAlertController(title: "単語を追加", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let action1 = UIAlertAction(title: "写真から追加する", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toSelectWordByCameraView", sender: nil)
        })
        let action2 = UIAlertAction(title: "単語を選ぶ", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toSelectSetWordView", sender: nil)
        })
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true, completion: nil)
    }
    
    @IBAction func startButtonPressed() {
        let words = realm.objects(Word.self)
        if words.count >= 4 {
            performSegue(withIdentifier: "toQuizView", sender: nil)
        }else {
            let alert = UIAlertController(title: "エラー", message: "4つ以上の単語が必要です", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteWord(indexPath: IndexPath) {
        var words = Array(set.words)
        words.remove(at: indexPath.row - 1)
        
        guard let editedSet = realm.object(ofType: Sets.self, forPrimaryKey: setID!) else { return }
        RealmService.shared.update(editedSet, with: ["words": words])
        
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectSetWordView" {
            let selectView: SelectSetWordViewController = segue.destination as! SelectSetWordViewController
            selectView.setID = set.setID
        }else if segue.identifier == "toQuizView" {
            let quizView: QuizViewController = segue.destination as! QuizViewController
            quizView.set = set
        }else if segue.identifier == "toSetWordView" {
            let wordView: WordViewController = segue.destination as! WordViewController
            wordView.word = selectedWord
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
            cell.backgroundColor = nil
            cell.gradientView.startColor = Color.shared.colorUI(num: set.color, type: 0)
            cell.gradientView.endColor = Color.shared.colorUI(num: set.color, type: 1)
            cell.setupGradientView()
            cell.data = set.correctAnsRate
            cell.backgroundColor = Color.shared.backgroundColor
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            if searchController.searchBar.text == "" {
                cell.textLabel?.text = set.words[indexPath.row - 1].word
            }else {
                cell.textLabel?.text = searchResults[indexPath.row - 1].word
            }
            cell.backgroundColor = Color.shared.backgroundColor
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
        selectedWord = set.words[indexPath.row - 1]
        performSegue(withIdentifier: "toSetWordView", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alert = UIAlertController(title: "削除", message: "この単語を削除しますか？", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
                self.deleteWord(indexPath: indexPath)
            })
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
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
