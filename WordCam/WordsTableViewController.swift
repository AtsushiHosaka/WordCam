//
//  WordsTableViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/06/27.
//

import UIKit
import RealmSwift

class WordsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    let realm = try! Realm()
    var data: Results<Sets>?
    var words = [String]()
    @IBOutlet var wordsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        reloading()
    }
    
    func reloading() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        data = read()
        wordsTableView.reloadData()
    }

    func read() -> Results<Sets> {
        return realm.objects(Sets.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        return cell
    }
}
