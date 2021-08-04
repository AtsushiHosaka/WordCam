//
//  MainViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/15.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating {
    
    let realm = try! Realm()
    let color = Color()
    var data: Results<Sets>?
    var selectedSet = Sets()
    @IBOutlet var setCollection: UICollectionView!
    @IBOutlet var addSetBtn: UIButton!
    @IBOutlet var alertLabel: UILabel!
    var searchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-----test-----
        try! realm.write{
            realm.deleteAll()
        }
        let testArray: [String: Any] = ["title": "test", "emoji": "🥺", "color": 2,
                                        "words": [["word": "test1", "meaning": "テスト1", "correctAnsRate": [
                                                    ["date": Date(), "rate": 0.3],
                                                    ["date": Date(), "rate": 0.6]]],
                                                  ["word": "test2", "meaning": "テスト2", "correctAnsRate": [
                                                    ["date": Date(), "rate": 0.4],
                                                    ["date": Date(), "rate": 0.8]]]
                                        ]]

        let testData = Sets(value: testArray)
        
        try! realm.write{
            realm.add(testData)
        }
        //----test----
        
        setCollection.dataSource = self
        setCollection.delegate = self
        
        self.navigationController?.navigationBar.sizeToFit()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = true
        
        addSetBtn.layer.cornerRadius = 30
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumInteritemSpacing = self.view.bounds.width * 15 / 375
        collectionLayout.minimumLineSpacing = self.view.bounds.height * 22 / 812
        collectionLayout.sectionInset = UIEdgeInsets(
            top:    self.view.bounds.height * 18 / 812,
            left:   self.view.bounds.width  * 16 / 375,
            bottom: self.view.bounds.height * 18 / 812,
            right:  self.view.bounds.width  * 16 / 375
        )
        collectionLayout.itemSize = CGSize(
            width:  self.view.bounds.width  * 164 / 375,
            height: self.view.bounds.height * 114 / 812
        )
        setCollection.collectionViewLayout = collectionLayout
        
        reloading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.searchController = searchController
    }
    
    func reloading() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        data = realm.objects(Sets.self)
        if data?.count == 0 {
            setCollection.isHidden = true
            alertLabel.isHidden = false
        }else {
            setCollection.isHidden = false
            alertLabel.isHidden = true
        }
        setCollection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SetCollectionViewCell
        cell.titleLabel.text = data?[indexPath.row].title
        cell.emojiLabel.text = data?[indexPath.row].emoji
        cell.layer.backgroundColor = color.colorCG(num: (data?[indexPath.row].color)!)
        //cell.correctAnsRateLabel.text = String((data?[indexPath.row].correctAnsRate)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSet = data![indexPath.row]
        performSegue(withIdentifier: "toSetView", sender: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetView" {
            let setView: SetViewController = segue.destination as! SetViewController
            setView.set = selectedSet
        }else if segue.identifier == "toAddSetView" {
            let addSetViewController: AddSetViewController = segue.destination as! AddSetViewController
            addSetViewController.reloading = reloading
        }
    }
    
    @IBAction func toAddSetView() {
        performSegue(withIdentifier: "toAddSetView", sender: nil)
    }
    
}

