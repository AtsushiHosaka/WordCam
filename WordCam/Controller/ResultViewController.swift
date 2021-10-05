//
//  ResultViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/08.
//

import UIKit
import SwiftDate

class ResultViewController: UIViewController {
    
    var correctAnsRate: Double?
    var resultText: String?
    var wrongWords = [Word]()
    var setID: String?
    var set: WordSet?
    @IBOutlet var correctAnsRateLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var retryButton: UIButton!
    @IBOutlet var resultChartView: ResultChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupTableView()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
        
        showShape()
        
        reloadNavigationController()
        reloadTabBarController()
        
        updateData()
        makeSetNotification()
    }
    
    func setupNavigationController() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupButton() {
        retryButton.layer.cornerRadius = retryButton.bounds.height / 2
        retryButton.layer.cornerCurve = .continuous
    }
    
    func reloadNavigationController() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = set?.title ?? ""
    }
    
    func reloadTabBarController() {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func reloadData() {
        setID = UserDefaults.standard.string(forKey: "setID")
        set = RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: setID)
        correctAnsRateLabel.text = String(Int(floor((correctAnsRate ?? 0) * 100))) + "%"
        tableView.reloadData()
    }
    
    @IBAction func retryButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonPressed() {
        let num = (self.navigationController?.viewControllers.count)! - 3
        navigationController?.popToViewController(navigationController!.viewControllers[num], animated: true)
    }
    
    func showShape() {
        resultChartView.color = set?.color ?? 0
        resultChartView.correctAnsRate = correctAnsRate ?? 0
    }
    
    func updateData() {
        let history = SetAnsHistory(date: Date(), rate: correctAnsRate!)
        guard let set = set else { return }
        var setCorrectAnsRates = Array(set.correctAnsRate)
        setCorrectAnsRates.append(history)
        RealmService.shared.update(set, with: ["correctAnsRate": setCorrectAnsRates])
        
        for word in set.words {
            var history = WordAnsHistory()
            if wrongWords.contains(word) {
                history = WordAnsHistory(date: Date(), rate: 0)
            }else {
                history = WordAnsHistory(date: Date(), rate: 1)
            }
            
            var wordCorrectAnsRates = Array(word.correctAnsRate)
            wordCorrectAnsRates.append(history)
            RealmService.shared.update(word, with: ["correctAnsRate": wordCorrectAnsRates])
        }
    }
    
    func makeSetNotification() {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.body = "今日も「\(set?.title ?? "セット")」で勉強しましょう"
        
        let startDate = UserDefaults.standard.object(forKey: "startDate") as! Date
        let dateDiffer = Date() - startDate
        let timer = 86400 - ((dateDiffer.hour ?? 0) * 3600 + (dateDiffer.minute ?? 0) * 60 + (dateDiffer.second ?? 0))
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timer), repeats: false)
        let request = UNNotificationRequest(identifier: "setNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResultWordView" {
            let wordView: WordViewController = segue.destination as! WordViewController
            let word = wrongWords[tableView.indexPathForSelectedRow?.row ?? 0]
            wordView.word = word
        }
    }
}

extension ResultViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        wrongWords.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        cell.textLabel?.text = wrongWords[indexPath.row].word
        return cell
    }
}

extension ResultViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toResultWordView", sender: nil)
    }
}
