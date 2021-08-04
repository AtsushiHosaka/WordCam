//
//  SetViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit
import Charts

class SetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var set = Sets()
    let color = Color()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var addAlertButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SetChartCell", bundle: nil), forCellReuseIdentifier: "SetChartCell")
        tableView.register(UINib(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "WordCell")
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //----test----
        print(set)
        self.navigationItem.title = set.title
        //--------
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        if set.words.count == 0 {
            tableView.isHidden = true
            alertLabel.isHidden = false
            addAlertButton.isHidden = false
        }else {
            tableView.isHidden = false
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
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell") as! WordTableViewCell
            cell.title.text = set.words[indexPath.row - 1].word
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
