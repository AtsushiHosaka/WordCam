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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupTableView()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showShape()
        reloadData()
        
        reloadNavigationController()
        reloadTabBarController()
        
        updateData()
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
        let trackLayer = CAShapeLayer()
        let center = CGPoint(x: view.center.x, y: 240)
        let trackCircularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi*2, clockwise: true)
        
        trackLayer.path = trackCircularPath.cgPath
        trackLayer.strokeColor = UIColor.systemGray6.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 20
        
        view.layer.addSublayer(trackLayer)
        
        let shapeLayer = CAShapeLayer()
        let shapeCircularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi*2 * (CGFloat(correctAnsRate ?? 0) - 0.25), clockwise: true)
        
        shapeLayer.path = shapeCircularPath.cgPath
        shapeLayer.strokeColor = MyColor.shared.colorCG(num: set?.color ?? 0, type: 1)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1
        animation.duration = 2
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        shapeLayer.add(animation, forKey: "animation")
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
