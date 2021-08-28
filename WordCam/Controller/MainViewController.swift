//
//  MainViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/15.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    let realm = RealmService.shared.realm
    var searchController = UISearchController(searchResultsController: nil)
    var data: Results<Sets>?
    var searchResults = [Sets]()
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var addSetBtn: UIButton!
    @IBOutlet var alertLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.navigationController?.navigationBar.sizeToFit()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupSearchController() {
        //searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = Color.shared.backgroundColor
        searchController.searchBar.barTintColor = Color.shared.backgroundColor
        
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
        data = realm.objects(Sets.self)
        if data?.count == 0 {
            collectionView.isHidden = true
            alertLabel.isHidden = false
        }else {
            collectionView.isHidden = false
            alertLabel.isHidden = true
        }
        
        collectionView.reloadData()
    }
    
    func reloadView() {
        reloadData()
        reloadNavigationController()
    }
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func toAddSetView() {
        performSegue(withIdentifier: "toAddSetView", sender: nil)
    }
    
    func showDeleteAlert(num: Int) {
        let alert = UIAlertController(title: "セットを削除しますか？", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.deleteSet(num: num)
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showEditAlert(_ sender: UIButton) {
        let alert = UIAlertController(title: "セットの編集", message: "", preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "編集", style: .default, handler: {(action: UIAlertAction!) -> Void in
            UserDefaults.standard.set(self.data![sender.tag].setID, forKey: "setID")
            self.performSegue(withIdentifier: "toEditSetView", sender: nil)
        })
        let deleteAction = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.showDeleteAlert(num: sender.tag)
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteSet(num: Int) {
        guard let set = data?[num] else { return }
        RealmService.shared.delete(set)
        data = realm.objects(Sets.self)
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddSetView" {
            let addSetViewController: AddSetViewController = segue.destination as! AddSetViewController
            addSetViewController.reloadCollectionView = reloadView
        }else if segue.identifier == "toEditSetView" {
            let editSetViewController: EditSetViewController = segue.destination as! EditSetViewController
            editSetViewController.reloadCollectionView = reloadView
        }
    }
    
    // test--------
    func testDelete() {
        try! realm.write {
            realm.deleteAll()
        }
        collectionView.reloadData()
    }
    
}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SetCollectionViewCell
        cell.titleLabel.text = data?[indexPath.row].title
        cell.emojiLabel.text = data?[indexPath.row].emoji
        cell.layer.backgroundColor = Color.shared.colorCG(num: data?[indexPath.row].color ?? 0)
        cell.correctAnsRateLabel.text = String(Int((data?[indexPath.row].correctAnsRate.last?.rate ?? 0) * 100)) + "%"
        
        cell.editButton.addTarget(self, action: #selector(showEditAlert(_:)), for: .touchUpInside)
        cell.editButton.tag = indexPath.row
        return cell
    }
    
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UserDefaults.standard.set(data![indexPath.row].setID, forKey: "setID")
        performSegue(withIdentifier: "toSetView", sender: nil)
    }
}

//extension MainViewController: UISearchResultsUpdating {
//
//    func updateSearchResults(for searchController: UISearchController) {
//        searchResults = data.filter { set in
//            return set.title.contains(searchController.searchBar.text!)
//        }
//
//        collectionView.reloadData()
//    }
//
//
//}
