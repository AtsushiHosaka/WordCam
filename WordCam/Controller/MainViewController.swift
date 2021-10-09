//
//  MainViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/15.
//

import UIKit
import NaturalLanguage
import CircleMenu

class MainViewController: UIViewController {
    
    let menuItems: [(icon: String, color: UIColor)] = [
        ("pencil", MyColor.shared.mainColor),
        ("", UIColor.clear),
        ("", UIColor.clear),
        ("magnifyingglass", MyColor.shared.mainColor)
    ]
    var searchController = UISearchController(searchResultsController: nil)
    var data = [WordSet]()
    var searchResults = [WordSet]()
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var alertLabel: UILabel!
    @IBOutlet var addSetMenu: CircleMenu!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //--test
        
        setupNavigationController()
        setupSearchController()
        setupTabBarController()
        setupMenu()
        setupCollectionView()
        setupTimeTrigger()
        
        makeRemindNotification()
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
        
        collectionView.register(UINib(nibName: "SetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
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
        tabBarController?.tabBar.shadowImage = UIImage()
        tabBarController?.tabBar.backgroundImage = UIImage()
        setTabBarImages(index: 0, image: "home_2.png", selectedImage: "home_1.png")
        setTabBarImages(index: 1, image: "words_2.png", selectedImage: "words_1.png")
    }
    
    func setTabBarImages(index: Int, image: String, selectedImage: String) {
        let item = tabBarController?.tabBar.items![index]
        let image = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
        
        item?.image = image
        item?.selectedImage = UIImage(named: selectedImage)?.withRenderingMode(.alwaysOriginal)
    }
    
    func setupMenu() {
        addSetMenu.delegate = self
        addSetMenu.backgroundColor = MyColor.shared.mainColor
        addSetMenu.tintColor = UIColor.white
        addSetMenu.setTitle("", for: .normal)
        let normalConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let selectedConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold, scale: .large)
        let normalImage = UIImage(systemName: "plus", withConfiguration: normalConfig)
        let selectedImage = UIImage(systemName: "xmark", withConfiguration: selectedConfig)
        addSetMenu.setImage(normalImage, for: .normal)
        addSetMenu.setImage(selectedImage, for: .selected)
        addSetMenu.layer.cornerRadius = addSetMenu.bounds.width / 2
    }
    
    func setupTimeTrigger() {
        let date = Date()
        UserDefaults.standard.set(date, forKey: "startDate")
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
    
    func showDeleteAlert(num: Int) {
        let action = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction!) -> Void in
            self.deleteSet(num: num)
        })
        let alert = MyAlert.shared.customAlert(title: "セットを削除しますか？", message: "", style: .alert, action: [action])
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showEditAlert(_ sender: UIButton) {
        let editAction = UIAlertAction(title: "編集", style: .default, handler: {(action: UIAlertAction!) -> Void in
            if self.searchController.searchBar.text == "" {
                UserDefaults.standard.set(self.data[sender.tag].setID, forKey: "setID")
            }else {
                UserDefaults.standard.set(self.searchResults[sender.tag].setID, forKey: "setID")
            }
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
        var set = WordSet()
        if searchController.searchBar.text == "" {
            set = data[num]
        }else {
            set = searchResults[num]
        }
        RealmService.shared.delete(set)
        if data.count == 1 {
            data = []
        }
        if searchResults.count == 1 {
            searchResults = []
        }
        
        reloadData()
    }
    
    func makeRemindNotification() {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.body = "前回の勉強から3日経過しました"
        
        let timer = 3 * 86400
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timer), repeats: false)
        let request = UNNotificationRequest(identifier: "remindNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
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
        if searchController.searchBar.text == "" {
            UserDefaults.standard.set(data[indexPath.row].setID, forKey: "setID")
        }else {
            UserDefaults.standard.set(searchResults[indexPath.row].setID, forKey: "setID")
        }
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

extension MainViewController: CircleMenuDelegate {
    
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.tintColor = UIColor.white
        button.backgroundColor = menuItems[atIndex].color
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: menuItems[atIndex].icon, withConfiguration: configuration), for: .normal)
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        addSetMenu.isSelected = false
        if atIndex == 0 {
            performSegue(withIdentifier: "toAddSetView", sender: nil)
        }else if atIndex == 3 {
            performSegue(withIdentifier: "toSearchSetView", sender: nil)
        }
    }
}
