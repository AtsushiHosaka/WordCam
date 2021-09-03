//
//  MainViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/15.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    var searchController = UISearchController(searchResultsController: nil)
    var data = [WordSet]()
    var searchResults = [WordSet]()
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var addSetBtn: UIButton!
    @IBOutlet var alertLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //test
        //print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
//        let testword = Word(word: "puppy", meanings: [Meaning(meaning: "子犬", type: 0)])
//        testword.correctAnsRate.append(WordAnsHistory(date: Date(), rate: 0.3))
//        testword.correctAnsRate.append(WordAnsHistory(date: Date(), rate: 0.8))
//        testword.correctAnsRate.append(WordAnsHistory(date: Date(), rate: 0.6))
//        RealmService.shared.create(testword)
        //testDelete()
        
        setupNavigationController()
        setupSearchController()
        setupTabBarController()
        setupButton()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
        reloadNavigationController()
    }
    
    func setupNavigationController() {
        navigationController?.navigationBar.sizeToFit()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = MyColor.shared.backgroundColor
        searchController.searchBar.barTintColor = MyColor.shared.backgroundColor
        
        navigationItem.searchController = searchController
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumInteritemSpacing = self.view.bounds.width * 15 / 375
        collectionLayout.minimumLineSpacing = self.view.bounds.width * 22 / 375
        collectionLayout.sectionInset = UIEdgeInsets(
            top:    self.view.bounds.width * 18 / 375,
            left:   self.view.bounds.width * 16 / 375,
            bottom: self.view.bounds.width * 18 / 375,
            right:  self.view.bounds.width * 16 / 375
        )
        collectionLayout.itemSize = CGSize(
            width:  self.view.bounds.width * 164 / 375,
            height: self.view.bounds.width * 114 / 375
        )
        
        collectionView.collectionViewLayout = collectionLayout
    }
    
    func setupTabBarController() {
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        setTabBarImages(index: 0, image: "home_2.png", selectedImage: "home_1.png")
        setTabBarImages(index: 1, image: "words_2.png", selectedImage: "words_1.png")
    }
    
    func setTabBarImages(index: Int, image: String, selectedImage: String) {
        let item = self.tabBarController?.tabBar.items![index]
        let image = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
        
        item?.image = image
        item?.selectedImage = UIImage(named: selectedImage)?.withRenderingMode(.alwaysOriginal)
    }
    
    func setupButton() {
        addSetBtn.layer.cornerRadius = addSetBtn.bounds.width / 2
    }
    
    func reloadData() {
        data = Array(RealmService.shared.realm.objects(WordSet.self))
        
        if data.count == 0 {
            collectionView.isHidden = true
            alertLabel.isHidden = false
        }else {
            collectionView.isHidden = false
            alertLabel.isHidden = true
        }
        
        let histories = RealmService.shared.realm.objects(WordAnsHistory.self)
        if histories.count > 20 {
            if RealmService.shared.realm.object(ofType: WordSet.self, forPrimaryKey: "auto") != nil {
                addAutoSet(isExist: true)
            }else {
                addAutoSet(isExist: false)
            }
        }
        
        collectionView.reloadData()
    }
    
    func reloadView() {
        reloadData()
        reloadNavigationController()
    }
    
    func reloadNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func toAddSetView() {
        performSegue(withIdentifier: "toAddSetView", sender: nil)
    }
    
    func showDeleteAlert(num: Int) {
        let action = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.deleteSet(num: num)
        })
        let alert = MyAlert.shared.customAlert(title: "セットを削除しますか？", message: "", style: .alert, action: [action])
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showEditAlert(_ sender: UIButton) {
        let editAction = UIAlertAction(title: "編集", style: .default, handler: {(action: UIAlertAction!) -> Void in
            UserDefaults.standard.set(self.data[sender.tag].setID, forKey: "setID")
            self.performSegue(withIdentifier: "toEditSetView", sender: nil)
        })
        let deleteAction = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.showDeleteAlert(num: sender.tag)
        })
        let alert = MyAlert.shared.customAlert(title: "セットの編集", message: "", style: .actionSheet, action: [editAction, deleteAction])
        self.present(alert, animated: true, completion: nil)
    }
    
    func addAutoSet(isExist: Bool) {
        var words = Array(RealmService.shared.realm.objects(Word.self))
        words.sort(by: {$0.word < $1.word})
    }
    
    func deleteSet(num: Int) {
        let set = data[num]
        RealmService.shared.delete(set)
        data = Array(RealmService.shared.realm.objects(WordSet.self))
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddSetView" {
            let addSetViewController: EditSetViewController = segue.destination as! EditSetViewController
            addSetViewController.type = 0
            addSetViewController.reloadCollectionView = reloadView
            
        }else if segue.identifier == "toEditSetView" {
            let editSetViewController: EditSetViewController = segue.destination as! EditSetViewController
            editSetViewController.type = 1
            editSetViewController.reloadCollectionView = reloadView
        }
    }
    
    // test--------
    func testDelete() {
        try! RealmService.shared.realm.write {
            RealmService.shared.realm.deleteAll()
        }
        collectionView.reloadData()
    }
    
}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.searchBar.text == "" {
            return data.count
        }else {
            return searchResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SetCollectionViewCell
        
        if searchController.searchBar.text == "" {
            cell.setData = data[indexPath.row]
        }else {
            cell.setData = searchResults[indexPath.row]
        }
        
        cell.editButton.addTarget(self, action: #selector(showEditAlert(_:)), for: .touchUpInside)
        cell.editButton.tag = indexPath.row
        
        return cell
    }
    
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UserDefaults.standard.set(data[indexPath.row].setID, forKey: "setID")
        performSegue(withIdentifier: "toSetView", sender: nil)
    }
}

extension MainViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        searchResults = data.filter { set in
            return set.title.contains(searchController.searchBar.text!)
        }
        
        collectionView.reloadData()
    }
}
