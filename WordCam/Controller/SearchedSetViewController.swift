//
//  SearchedSetViewController.swift
//  SearchedSetViewController
//
//  Created by 保坂篤志 on 2021/10/06.
//

import UIKit

class SearchedSetViewController: UIViewController {
    
    var type = "default"
    var setData = WordSet()
    var words = [Word]()
    var selectedNum = 0
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadNavigationController()
        reloadData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func reloadNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = false
        self.title = setData.title
    }
    
    func reloadData() {
        let array = Array(setData.words)
        words = array.sorted(by: { $0.word < $1.word })
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed() {
        showAddAlert()
    }
    
    @objc func addSet() {
        let sets = Array(RealmService.shared.realm.objects(WordSet.self))
        
        if sets.contains(setData) {
            showUnableAlert()
        }else {
            SetDownloader.shared.addNewSet(path: type, setData: setData)
            showFinishAlert()
        }
    }
    
    func showAddAlert() {
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            
            self.addSet()
        })
        let alert = MyAlert.shared.customAlert(title: "このセットを追加しますか？", message: "", style: .alert, action: [action])
        present(alert, animated: true, completion: nil)
    }
    
    func showFinishAlert() {
        let alert = UIAlertController(title: "完了しました！", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showUnableAlert() {
        let alert = UIAlertController(title: "このセットはすでに追加されています", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let wordViewController: WordViewController = segue.destination as! WordViewController
        wordViewController.word = words[selectedNum]
        wordViewController.isEditable = false
    }
}

extension SearchedSetViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = words[indexPath.row].word
        
        return cell
    }
}

extension SearchedSetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNum = indexPath.row
        performSegue(withIdentifier: "toSearchedWordView", sender: nil)
    }
}
