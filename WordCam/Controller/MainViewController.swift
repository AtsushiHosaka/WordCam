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
    let color = Color()
    var data: Results<Sets>?
    var selectedSet = Sets()
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var addSetBtn: UIButton!
    @IBOutlet var alertLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupTabBarController()
        setupButton()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
        reloadNavigationController()
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
    
    func setupNavigationController() {
        self.navigationController?.navigationBar.sizeToFit()
        self.navigationController?.navigationBar.shadowImage = UIImage()
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
    
    func updateSearchResults(for searchController: UISearchController) {

    }
    
    func deleteSet(num: Int) {
        guard let set = data?[num] else { return }
        RealmService.shared.delete(set)
        data = realm.objects(Sets.self)
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetView" {
            UserDefaults.standard.set(selectedSet.setID, forKey: "setID")
        }else if segue.identifier == "toAddSetView" {
            let addSetViewController: AddSetViewController = segue.destination as! AddSetViewController
            addSetViewController.reloadCollectionView = reloadView
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
        cell.layer.backgroundColor = color.colorCG(num: (data?[indexPath.row].color)!)
        cell.correctAnsRateLabel.text = String(Int((data?[indexPath.row].correctAnsRate.last?.rate ?? 0) * 100)) + "%"
        cell.deleteAlert = {
            let alert = UIAlertController(title: "セットを削除", message: "この操作は取り消せません", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
                self.deleteSet(num: indexPath.row)
            })
            let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        return cell
    }
    
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSet = data![indexPath.row]
        performSegue(withIdentifier: "toSetView", sender: nil)
    }
}
