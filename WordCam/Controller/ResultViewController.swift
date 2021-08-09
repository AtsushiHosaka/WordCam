//
//  ResultViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/08.
//

import UIKit

class ResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = RealmService.shared.realm
    var correctAnsRate: Double?
    var resultText: String?
    var wrongWords = [String]()
    var setID: String?
    @IBOutlet var correctAnsRateLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var retryButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        retryButton.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        
        correctAnsRateLabel.text = resultText
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        wrongWords.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = wrongWords[indexPath.row]
        return cell
    }
    
    @IBAction func retryButtonPressed() {
        updateData()
        let presentView = self.presentingViewController as! QuizViewController
        presentView.setID = setID
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonPressed() {
        updateData()
        let num = (navigationController?.viewControllers.count)! - 3
        navigationController?.popToViewController(navigationController!.viewControllers[num], animated: true)
    }
    
    func updateData() {
        let history = SetAnsHistory(date: Date(), rate: correctAnsRate!)
        guard let set = realm.object(ofType: Sets.self, forPrimaryKey: setID) else {return}
        var correctAnsRates = Array(set.correctAnsRate)
        correctAnsRates.append(history)
        
        RealmService.shared.update(set, with: ["correctAnsRate": correctAnsRates])
    }
}
