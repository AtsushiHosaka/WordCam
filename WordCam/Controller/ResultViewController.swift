//
//  ResultViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/08.
//

import UIKit
import Charts

class ResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = RealmService.shared.realm
    let color = Color()
    var correctAnsRate: Double?
    var resultText: String?
    var wrongWords = [String]()
    var setID: String?
    var set: Sets?
    @IBOutlet var correctAnsRateLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var retryButton: UIButton!
    @IBOutlet var pieChart: PieChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        retryButton.layer.cornerRadius = retryButton.bounds.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        
        setID = UserDefaults.standard.string(forKey: "setID")
        set = realm.object(ofType: Sets.self, forPrimaryKey: setID)
        self.title = set?.title ?? ""
        correctAnsRateLabel.text = String(Int(floor((correctAnsRate ?? 0) * 100))) + "%"
        
        showPieChart()
        tableView.reloadData()
        
        updateData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        wrongWords.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        cell.textLabel?.text = wrongWords[indexPath.row]
        return cell
    }
    
    func showPieChart() {
        var entries = [PieChartDataEntry]()
        entries.append(PieChartDataEntry(value: (correctAnsRate ?? 0) * 100))
        entries.append(PieChartDataEntry(value: 100 - (correctAnsRate ?? 0) * 100))
        
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.drawValuesEnabled = false
        dataSet.colors = [color.colorUI(num: set?.color ?? 0), UIColor(white: 249/255, alpha: 0)]
        
        pieChart.legend.enabled = false
        pieChart.drawEntryLabelsEnabled = false
        
        pieChart.data = PieChartData(dataSet: dataSet)
    }
    
    @IBAction func retryButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonPressed() {
        let num = (self.navigationController?.viewControllers.count)! - 3
        navigationController?.popToViewController(navigationController!.viewControllers[num], animated: true)
    }
    
    func updateData() {
        let history = SetAnsHistory(date: Date(), rate: correctAnsRate!)
        guard let set = set else { return }
        var correctAnsRates = Array(set.correctAnsRate)
        correctAnsRates.append(history)
        
        RealmService.shared.update(set, with: ["correctAnsRate": correctAnsRates])
    }
}
