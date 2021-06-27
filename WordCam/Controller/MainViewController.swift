//
//  MainViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/15.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let realm = try! Realm()
    let colorModel = Color()
    var sets: Results<Sets>?
    var selectedSet = Sets()
    @IBOutlet var setCollection: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-----test-----
        try! realm.write{
            realm.deleteAll()
        }
        let testArray: [String: Any] = ["title": "test",
                     "correctAnsRate": 1,
                     "emoji": "🥺",
                     "color": "blue",
                     "words": [["english": "test1",
                                "meaning": "テスト1"],
                               ["english": "test2",
                                          "meaning": "テスト2"]
                     ]]
        
        let testData = Sets(value: testArray)
        
        try! realm.write{
            realm.add(testData)
        }
        //----test----
        
        setCollection.dataSource = self
        setCollection.delegate = self
        setCollection.reloadData()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: 180, height: 130)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        
        sets = read()
    }

    func read() -> Results<Sets> {
        return realm.objects(Sets.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sets!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SetCollectionViewCell
        cell.titleLabel.text = sets?[indexPath.row].title
        cell.emojiLabel.text = sets?[indexPath.row].emoji
        cell.layer.backgroundColor = colorModel.colorCode(code: (sets?[indexPath.row].color)!)
        cell.correctAnsRateLabel.text = String((sets?[indexPath.row].correctAnsRate)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSet = sets![indexPath.row]
        performSegue(withIdentifier: "toSetView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetView" {
            let setView: SetViewController = segue.destination as! SetViewController
            setView.sets = selectedSet
        }
    }
    
}

