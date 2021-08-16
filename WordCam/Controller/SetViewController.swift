//
//  SetViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit
import Charts

class SetViewController: UIViewController {
    
    var set = Sets()
    var setID: String?
    let color = Color()
    let realm = RealmService.shared.realm
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var addAlertButton: UIButton!
    @IBOutlet var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
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
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "SetChartCell", bundle: nil), forCellReuseIdentifier: "SetChartCell")
        tableView.register(UINib(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "WordCell")
    }
    
    func setupButton() {
        startButton.layer.cornerRadius = startButton.bounds.height / 2
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
        
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed() {
        let alertSheet = UIAlertController(title: "単語を追加", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let action1 = UIAlertAction(title: "単語を選ぶ", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toSelectSetWordView", sender: nil)
        })
        let action2 = UIAlertAction(title: "写真から追加する", style: .default, handler: {(action: UIAlertAction!) -> Void in
            //写真から追加
        })
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true, completion: nil)
    }
    
    @IBAction func startButtonPressed() {
        performSegue(withIdentifier: "toQuizView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectSetWordView" {
            let selectView: SelectSetWordViewController = segue.destination as! SelectSetWordViewController
            selectView.setID = set.setID
        }else if segue.identifier == "toQuizView" {
            let quizView: QuizViewController = segue.destination as! QuizViewController
            quizView.set = set
        }
    }
}

extension SetViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return set.words.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SetChartCell") as! SetChartCell
            cell.backgroundColor = nil
            cell.backgroundLabel.backgroundColor = color.colorUI(num: set.color)
            cell.data = set.correctAnsRate
            cell.backgroundColor = color.backgroundColor
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = set.words[indexPath.row - 1].word
            cell.backgroundColor = color.backgroundColor
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 250
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
}
