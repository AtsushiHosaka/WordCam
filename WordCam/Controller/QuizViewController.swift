//
//  QuizViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/04.
//

import UIKit

class QuizViewController: UIViewController {
    
    let realm = RealmService.shared.realm
    var set = Sets()
    var setID: String?
    var words = [[String]]()
    var meanings = [String]()
    var wrongWords = [String]()
    var dummyMeanings = [String]()
    var questionCount: Int?
    var correctAnsCount: Int?
    var correctAnsNum: Int?
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var timeBarBackgroundLabel: UILabel!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var timeBar: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
        setupLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadNavigationController()
        reloadData()
        
        startSetting()
    }
    
    func setupButton() {
        button1.layer.borderWidth = 5.0
        button2.layer.borderWidth = 5.0
        button3.layer.borderWidth = 5.0
        button4.layer.borderWidth = 5.0
        button1.layer.borderColor = CGColor(red: 31/255, green: 71/255, blue: 107/255, alpha: 1.0)
        button2.layer.borderColor = CGColor(red: 31/255, green: 71/255, blue: 107/255, alpha: 1.0)
        button3.layer.borderColor = CGColor(red: 31/255, green: 71/255, blue: 107/255, alpha: 1.0)
        button4.layer.borderColor = CGColor(red: 31/255, green: 71/255, blue: 107/255, alpha: 1.0)
        button1.layer.cornerRadius = 15
        button2.layer.cornerRadius = 15
        button3.layer.cornerRadius = 15
        button4.layer.cornerRadius = 15
    }
    
    func setupLabel() {
        timeBar.transform = CGAffineTransform(scaleX: 1.0, y: 15.0)
        timeBar.layer.cornerRadius = timeBar.bounds.height / 2
        timeBar.clipsToBounds = true
        timeBarBackgroundLabel.layer.cornerRadius = timeBarBackgroundLabel.bounds.height / 2
        timeBarBackgroundLabel.clipsToBounds = true
    }
    
    func reloadNavigationController() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func reloadData() {
        setID = UserDefaults.standard.string(forKey: "setID")
        set = realm.object(ofType: Sets.self, forPrimaryKey: setID) ?? Sets()
    }
    
    @IBAction func ansBtnPressed(_ sender: UIButton) {
        if sender.tag == correctAnsNum {
            correctAnsCount! += 1
        }else {
            wrongWords.append(words[questionCount!][0])
        }
        
        questionCount! += 1
        if questionCount! == words.count {
            endSetting()
        }else {
            prepareNextQuestion()
        }
    }
    
    @IBAction func stopButtonPressed() {
        let alert = UIAlertController(title: "中断しますか？", message: "再開することはできません", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.stop()
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func startSetting() {
        questionCount = 0
        correctAnsCount = 0
        words = []
        wrongWords = []
        for data in set.words {
            words.append([data.word, data.meanings[0]])
        }
        
        let dummyData = realm.objects(Word.self)
        for data in dummyData {
            dummyMeanings.append(data.meanings[0])
        }
        
        
        prepareNextQuestion()
    }
    
    func prepareNextQuestion() {
        
        wordLabel.text = words[questionCount!][0]
        
        meanings = ["", "", "", ""]
        correctAnsNum = Int.random(in: 0...3)
        var dummy = dummyMeanings
        
        meanings[correctAnsNum!] = words[questionCount!][1]
        for i in 0...3 {
            if i != correctAnsNum {
                var n = Int.random(in: 0..<dummy.count)
                while dummy[n] == words[questionCount!][1] || meanings.contains(dummy[n]) {
                    n = Int.random(in: 0..<dummy.count)
                }
                meanings[i] = dummy[n]
                dummy.remove(at: n)
            }
        }
        
        button1.setTitle(meanings[0], for: .normal)
        button2.setTitle(meanings[1], for: .normal)
        button3.setTitle(meanings[2], for: .normal)
        button4.setTitle(meanings[3], for: .normal)
    }
    
    func endSetting() {
        performSegue(withIdentifier: "toResultView", sender: nil)
    }
    
    func stop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResultView" {
            let resultView: ResultViewController = segue.destination as! ResultViewController
            resultView.correctAnsRate = Double(correctAnsCount!) / Double(words.count)
            resultView.resultText = String(correctAnsCount!) + "/" + String(words.count)
            resultView.wrongWords = wrongWords
        }
    }
}
