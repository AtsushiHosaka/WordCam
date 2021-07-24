//
//  SetViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/30.
//

import UIKit
import Charts

class SetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var sets = Sets()
    @IBOutlet var tableView: UITableView!
    let color = Color()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ChartTableViewCell", bundle: nil), forCellReuseIdentifier: "ChartCell")
        tableView.register(UINib(nibName: "WordTableViewCell", bundle: nil), forCellReuseIdentifier: "WordCell")
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //----test----
        print(sets)
        self.navigationItem.title = sets.title
        //--------
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.words.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell") as! ChartTableViewCell
            cell.backgroundColor = nil
            cell.backgroundLabel.backgroundColor = color.colorUI(code: sets.color)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell") as! WordTableViewCell
            cell.title.text = sets.words[indexPath.row - 1].english
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
