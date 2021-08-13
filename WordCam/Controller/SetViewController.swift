//
//  SetViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit
import Charts

class SetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "SetChartCell", bundle: nil), forCellReuseIdentifier: "SetChartCell")
        tableView.register(UINib(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "WordCell")
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        startButton.layer.cornerRadius = startButton.bounds.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell") as! WordTableViewCell
            cell.title.text = set.words[indexPath.row - 1].word
            cell.backgroundColor = color.backgroundColor
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            return nil
        }else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 250
        }else {
            return 50
        }
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
    
    @IBAction func addButtonPressed() {
        let alertSheet = UIAlertController(title: "単語を追加", message: "単語の追加方法を選択してください", preferredStyle: UIAlertController.Style.actionSheet)
        let action1 = UIAlertAction(title: "単語を選ぶ", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toSelectSetWordView", sender: nil)
        })
        let action2 = UIAlertAction(title: "写真から追加する", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            print("sita")
        })
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler: {(action: UIAlertAction!) -> Void in
            print("can")
        })
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.addAction(cancelAction)
        present(alertSheet, animated: true, completion: nil)
    }
    
    @IBAction func startButtonPressed() {
        performSegue(withIdentifier: "toQuizView", sender: nil)
    }
    
    @IBAction func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}
