//
//  AddWordsByCameraViewController.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/08/15.
//

import UIKit
import Vision
import VisionKit

class AddWordsByCameraViewController: UIViewController {
    
    var words = [String]()
    var requests = [VNRequest]()
    var isOpenCamera: Bool = true
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupTableView()
        setupVision()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadNavigationController()
        
        if isOpenCamera {
            presentCameraView()
        }
        isOpenCamera = !isOpenCamera
    }
    
    func setupNavigationController() {
        self.title = "登録する単語を選択"
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
    }
    
    func setupVision() {
        let textRecognitionRequest = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                if String(candidate.string.unicodeScalars.filter(CharacterSet.letters.contains).map(Character.init)) == candidate.string && candidate.string.count != 1 {
                    self.words.append(candidate.string)
                }
            }
        }
        
        textRecognitionRequest.recognitionLevel = .accurate
        self.requests = [textRecognitionRequest]
    }
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func reloadData() {
        if words.isEmpty {
            showNullAlert()
        }else {
            tableView.reloadData()
        }
    }
    
    @IBAction func okButtonPressed() {
        if tableView.indexPathsForSelectedRows?.count ?? 0 == 0 {
            showErrorAlert()
        }else {
            performSegue(withIdentifier: "toInputWordView", sender: nil)
        }
    }
    
    @IBAction func cameraButtonPressed() {
        if isOpenCamera == true {
            isOpenCamera = false
        }
        presentCameraView()
    }
    
    func presentCameraView() {
        words = []
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    func showErrorAlert() {
        let alert = MyAlert.shared.errorAlert(message: "単語を選択してください")
        present(alert, animated: true, completion: nil)
    }
    
    func showNullAlert() {
        let alert = UIAlertController(title: "単語が検出されませんでした", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true, completion: nil)
            self.isOpenCamera = false
            self.presentCameraView()
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputView: InputWordViewController = segue.destination as! InputWordViewController
        
        inputView.type = 0
        
        var selectedWords = [String]()
        
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            selectedWords.append(words[indexPath.row])
        }
        inputView.words = selectedWords
    }
}

extension AddWordsByCameraViewController: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)

        let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                                 qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        textRecognitionWorkQueue.async {
            self.words = []
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let cgImage = image.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print(error)
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                self.reloadData()
            })
        }
    }
}

extension AddWordsByCameraViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = words[indexPath.row]
        cell.backgroundColor = MyColor.shared.backgroundColor
        return cell
    }
}

extension AddWordsByCameraViewController: UITableViewDelegate {
    
}
