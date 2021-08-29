//
//  ResultViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/08.
//

import UIKit

class ResultViewController: UIViewController {
    
    let realm = RealmService.shared.realm
    var correctAnsRate: Double?
    var resultText: String?
    var wrongWords = [String]()
    var setID: String?
    var set: Sets?
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
        set = realm.object(ofType: Sets.self, forPrimaryKey: setID)
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
        shapeLayer.strokeColor = Color.shared.colorCG(num: set?.color ?? 0, type: 1)
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
        var correctAnsRates = Array(set.correctAnsRate)
        correctAnsRates.append(history)
        
        RealmService.shared.update(set, with: ["correctAnsRate": correctAnsRates])
    }
}

extension ResultViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        wrongWords.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        cell.textLabel?.text = wrongWords[indexPath.row]
        return cell
    }
}

extension ResultViewController: UITableViewDelegate {
    
}
