//
//  SearchSetViewController.swift
//  SearchSetViewController
//
//  Created by 保坂篤志 on 2021/10/06.
//

import UIKit
import SwiftUI

class SearchSetViewController: UIViewController {
    
    var data = [WordSet]() {
        didSet {
            if data.count == 0 {
                showErrorAlert()
            }else {
                collectionView.reloadData()
            }
        }
    }
    var type = "default"
    var selectedNum = 0
    var searchController = UISearchController(searchResultsController: nil)
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupCollectionView()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if searchController.searchBar.text!.count == 36 {
            readOriginalSet(ID: searchController.searchBar.text!)
        }else {
            readDefaultSets()
        }
    }
    
    func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.sizeToFit()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.hidesSearchBarWhenScrolling = false
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
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = MyColor.shared.backgroundColor
        searchController.searchBar.barTintColor = MyColor.shared.backgroundColor
        
        navigationItem.searchController = searchController
    }
    
    func addSet(selectedNum: Int) {
        let setData = data[selectedNum]
        SetDownloader.shared.addNewSet(path: type, setData: setData)
        showFinishAlert()
    }
    
    func readDefaultSets() {
        SetSearcher.shared.readSetData(path: "default", ID: nil, completionHandler: { data in
            self.data = data
        })
    }
    
    func readOriginalSet(ID: String) {
        SetSearcher.shared.readSetData(path: "original", ID: ID, completionHandler: { data in
            self.data = data
        })
    }
    
    @objc func showAddAlert(_ sender: UIButton) {
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.addSet(selectedNum: sender.tag)
        })
        let alert = MyAlert.shared.customAlert(title: "このセットを追加しますか？", message: "", style: .alert, action: [action])
        present(alert, animated: true, completion: nil)
    }
    
    func showFinishAlert() {
        let alert = UIAlertController(title: "完了しました！", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "データを取得できませんでした", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let setViewController: SearchedSetViewController = segue.destination as! SearchedSetViewController
        setViewController.setData = data[selectedNum]
        setViewController.type = type
    }
}

extension SearchSetViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SetCollectionViewCell
        
        cell.setData = data[indexPath.row]
        
        cell.editButton.addTarget(self, action: #selector(showAddAlert(_:)), for: .touchUpInside)
        cell.editButton.tag = indexPath.row
        
        return cell
    }
}

extension SearchSetViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedNum = indexPath.row
        performSegue(withIdentifier: "toSearchedSetView", sender: nil)
    }
}

extension SearchSetViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
//        searchResults = data.filter { set in
//            return set.title.contains(searchController.searchBar.text!)
//        }
        
        if searchController.searchBar.text!.count == 36 {
            if type == "default" {
                type = "original"
                readOriginalSet(ID: searchController.searchBar.text!)
            }
        }else {
            if type == "original" {
                type = "default"
                readDefaultSets()
            }
        }
    }
}
