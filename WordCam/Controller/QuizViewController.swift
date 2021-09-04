//
//  QuizViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/04.
//

import UIKit

class QuizViewController: UIViewController {
    
    let shapeLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    let timeRimit: Int = 10
    var timer: Timer!
    var setID: String?
    var words = [Word]()
    var meanings = [String]()
    var wrongWords = [Word]()
    var dummyMeanings = [Meaning]()
    var questionCount: Int = 0
    var correctAnsCount: Int?
    var correctAnsNum: Int?
    var time: Int = 0
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var timerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
        setupAnimation()
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
    
    func setupAnimation() {
        animation.toValue = 0
        animation.duration = CFTimeInterval(timeRimit)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
    }
    
    func showShape() {
        let trackLayer = CAShapeLayer()
        let trackPath = UIBezierPath()
        trackPath.move(to: CGPoint(x: 60, y: timerView.bounds.height / 2))
        trackPath.addLine(to: CGPoint(x: self.view.bounds.width - 60, y: timerView.bounds.height / 2))
        
        trackLayer.path = trackPath.cgPath
        trackLayer.strokeColor = CGColor(red: 65/255, green: 67/255, blue: 89/255, alpha: 1.0)
        trackLayer.backgroundColor = nil
        trackLayer.lineWidth = 50
        trackLayer.lineCap = .round
        
        timerView.layer.addSublayer(trackLayer)
        
        let traceLayer = CAShapeLayer()
        let tracePath = UIBezierPath()
        tracePath.move(to: CGPoint(x: 60, y: timerView.bounds.height / 2))
        tracePath.addLine(to: CGPoint(x: self.view.bounds.width - 60, y: timerView.bounds.height / 2))
        
        traceLayer.path = trackPath.cgPath
        traceLayer.strokeColor = CGColor(red: 28/255, green: 40/255, blue: 103/255, alpha: 1.0)
        traceLayer.backgroundColor = nil
        traceLayer.lineWidth = 40
        traceLayer.lineCap = .round
        
        timerView.layer.addSublayer(traceLayer)
        
        let shapePath = UIBezierPath()
        shapePath.move(to: CGPoint(x: 60, y: timerView.bounds.height / 2))
        shapePath.addLine(to: CGPoint(x: self.view.bounds.width - 60, y: timerView.bounds.height / 2))
        
        shapeLayer.path = shapePath.cgPath
        shapeLayer.strokeColor = CGColor(red: 188/255, green: 0, blue: 160/255, alpha: 1.0)
        shapeLayer.backgroundColor = nil
        shapeLayer.lineWidth = 40
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 1
        
        timerView.layer.addSublayer(shapeLayer)
        
        shapeLayer.add(animation, forKey: "animation")
    }
    
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
        timer.fire()
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
        pauseAnimation()
        
        timer.invalidate()
        time += 1
        
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.stop()
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: {(action: UIAlertAction!) -> Void in
            self.setupTimer()
            self.resumeAnimation()
        })
        let alert = MyAlert.shared.customAlert(title: "中断しますか？", message: "再開することはできません", style: .alert, action: [action, cancel])
        present(alert, animated: true, completion: nil)
    }
    
    func pauseAnimation(){
        let pausedTime = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pausedTime
    }

    func resumeAnimation(){
        let pausedTime = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        let timeSincePause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        shapeLayer.beginTime = timeSincePause
    }
    
    func checkAnswer(num: Int) {
        timer.invalidate()
        
        if num == correctAnsNum {
            correctAnsCount! += 1
        }else {
            wrongWords.append(words[questionCount])
        }
        
        questionCount += 1
        if questionCount == words.count {
            endSetting()
        }else {
            prepareNextQuestion()
        }
    }
    
    func startSetting() {
        questionCount = 0
        correctAnsCount = 0
        words = []
        wrongWords = []
        
        let set = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID) ?? WordSet()
        for data in set.words {
            words.append(data)
        }
        words.shuffle()
        
        dummyMeanings = Array(RealmService.shared.realm.objects(Meaning.self))
        dummyMeanings += defaultDummyModel
        
        showShape()
        
        prepareNextQuestion()
    }
    
    func prepareNextQuestion() {
        shapeLayer.strokeEnd = 1
        shapeLayer.add(animation, forKey: "animation")
        
        time = timeRimit
        setupTimer()
        
        wordLabel.text = words[questionCount].word
        
        meanings = ["", "", "", ""]
        correctAnsNum = Int.random(in: 0...3)
        var dummy = dummyMeanings
        
        meanings[correctAnsNum!] = words[questionCount].meanings[0].meaning
        for i in 0...3 {
            if i != correctAnsNum {
                var n = Int.random(in: 0..<dummy.count)
                while dummy[n].meaning == words[questionCount].meanings[0].meaning ||
                        meanings.contains(dummy[n].meaning) ||
                        dummy[n].type != words[questionCount].meanings[0].type {
                    n = Int.random(in: 0..<dummy.count)
                }
                meanings[i] = dummy[n].meaning
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
            resultView.correctAnsRate = Double(correctAnsCount!) / Double(words.count)
            resultView.resultText = String(correctAnsCount!) + "/" + String(words.count)
            resultView.wrongWords = wrongWords
        }
    }
    
    let defaultDummyModel = [Meaning(meaning: "方法", type: 0),
                             Meaning(meaning: "乗客", type: 0),
                             Meaning(meaning: "材料", type: 0),
                             Meaning(meaning: "成分", type: 0),
                             Meaning(meaning: "〜を防ぐ", type: 1),
                             Meaning(meaning: "〜を用意する", type: 1),
                             Meaning(meaning: "〜を与える", type: 1),
                             Meaning(meaning: "〜を選ぶ", type: 1),
                             Meaning(meaning: "以前の", type: 2),
                             Meaning(meaning: "最近の", type: 2),
                             Meaning(meaning: "特定の", type: 2),
                             Meaning(meaning: "あいまいな", type: 2),
                             Meaning(meaning: "ますます", type: 3),
                             Meaning(meaning: "確かに", type: 3),
                             Meaning(meaning: "正確に", type: 3),
                             Meaning(meaning: "思いがけなく", type: 3),
                             Meaning(meaning: "できる", type: 4),
                             Meaning(meaning: "かもしれない", type: 4),
                             Meaning(meaning: "に違いない", type: 4),
                             Meaning(meaning: "するだろう", type: 4),
                             Meaning(meaning: "わたしは", type: 5),
                             Meaning(meaning: "あなたの", type: 5),
                             Meaning(meaning: "それを", type: 5),
                             Meaning(meaning: "私たち自身", type: 5),
                             Meaning(meaning: "〜までずっと", type: 6),
                             Meaning(meaning: "〜を横切って", type: 6),
                             Meaning(meaning: "〜のあちこちに", type: 6),
                             Meaning(meaning: "〜について", type: 6),
                             Meaning(meaning: "その", type: 7),
                             Meaning(meaning: "例の", type: 7),
                             Meaning(meaning: "あるひとつの", type: 7),
                             Meaning(meaning: "〜する間に", type: 8),
                             Meaning(meaning: "そして", type: 8),
                             Meaning(meaning: "または", type: 8),
                             Meaning(meaning: "だから", type: 8)]
}
