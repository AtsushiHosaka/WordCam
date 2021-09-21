//
//  QuizViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/04.
//

import UIKit

class QuizViewController: UIViewController {
    
    let timeRimit: Int = 10
    var time: Int = 0
    var timer: Timer!
    var setID: String?
    var wrongWords = [Word]()
    var questionCount: Int = 0
    var quizData = [Quiz]()
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var timerView: TimerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
        setupTimerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadNavigationController()
        reloadData()
        
        startSetting()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
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
        button1.layer.cornerCurve = .continuous
        button2.layer.cornerCurve = .continuous
        button3.layer.cornerCurve = .continuous
        button4.layer.cornerCurve = .continuous
    }
    
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func setupTimerView() {
        timerView.timeRimit = timeRimit
        timerView.setupAnimation()
    }
    
    func reloadNavigationController() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func reloadData() {
        setID = UserDefaults.standard.string(forKey: "setID")
    }
    
    @IBAction func ansButtonPressed(_ sender: UIButton) {
        checkAnswer(num: sender.tag)
    }
    
    @IBAction func pauseButtonPressed() {
        timerView.pauseAnimation()
        
        timer.invalidate()
        time += 1
        
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.stop()
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: {(action: UIAlertAction!) -> Void in
            self.setupTimer()
            self.timerView.resumeAnimation()
        })
        let alert = MyAlert.shared.customAlert(title: "中断しますか？", message: "再開することはできません", style: .alert, action: [action, cancel])
        present(alert, animated: true, completion: nil)
    }
    
    func checkAnswer(num: Int) {
        timer.invalidate()
        
        let correctAnsNum = quizData[questionCount].correctAnsNum
        if num != correctAnsNum {
            wrongWords.append(quizData[questionCount].word)
        }
        
        questionCount += 1
        if questionCount == quizData.count {
            endSetting()
        }else {
            prepareNextQuestion()
        }
    }
    
    func startSetting() {
        questionCount = 0
        wrongWords = []
        
        let set = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID) ?? WordSet()
        quizData = QuizSystem.shared.setupQuiz(words: Array(set.words))
        
        timerView.showShape()
        
        prepareNextQuestion()
    }
    
    func prepareNextQuestion() {
        timerView.initAnimation()
        
        time = timeRimit
        setupTimer()
        
        let quiz = quizData[questionCount]
        
        wordLabel.text = quiz.word.word
        button1.setTitle(quiz.choices[0], for: .normal)
        button2.setTitle(quiz.choices[1], for: .normal)
        button3.setTitle(quiz.choices[2], for: .normal)
        button4.setTitle(quiz.choices[3], for: .normal)
    }
    
    func endSetting() {
        performSegue(withIdentifier: "toResultView", sender: nil)
    }
    
    func stop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showTimeupAlert() {
        let alert = UIAlertController(title: "時間切れ", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true, completion: nil)
            self.checkAnswer(num: -1)
        }
    }
    
    @objc func updateTimerLabel() {
        timerLabel.text = String(time)
        time -= 1
        if time < 0 {
            timer.invalidate()
            showTimeupAlert()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResultView" {
            let resultView: ResultViewController = segue.destination as! ResultViewController
            let correctAnsCount = quizData.count - wrongWords.count
            resultView.correctAnsRate = Double(correctAnsCount) / Double(quizData.count)
            resultView.resultText = String(correctAnsCount) + "/" + String(quizData.count)
            resultView.wrongWords = wrongWords
        }
    }
}
