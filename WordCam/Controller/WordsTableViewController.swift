//
//  WordsTableViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/13.
//

import UIKit
import RealmSwift
import Charts

class WordsTableViewController: UITableViewController {
    
    
    //@IBOutlet var tableView: UITableView!
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func read() -> Results<Sets> {
        return realm.objects(Sets.self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        return cell
    }
}
