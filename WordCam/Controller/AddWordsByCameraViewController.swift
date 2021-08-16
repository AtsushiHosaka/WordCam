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
    
    let color = Color()
    var words = [String]()
    var isSelected = [Bool]()
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
                    self.isSelected.append(false)
                }
            }
        }
        
        textRecognitionRequest.recognitionLevel = .accurate
        self.requests = [textRecognitionRequest]
    }
    
    func reloadNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @IBAction func okButtonPressed() {
        performSegue(withIdentifier: "toInputWordView", sender: nil)
    }
    
    @IBAction func cameraButtonPressed() {
        if isOpenCamera == true {
            isOpenCamera = false
        }
        presentCameraView()
    }
    
    func presentCameraView() {
        words = []
        isSelected = []
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputView: InputWordViewController = segue.destination as! InputWordViewController
        
        var selectedWords = [String]()
        for i in 0..<words.count {
            if isSelected[i] {
                selectedWords.append(words[i])
            }
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
                self.tableView.reloadData()
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
        if isSelected[indexPath.row] {
            cell.backgroundColor = UIColor.lightGray
        }else {
            cell.backgroundColor = color.backgroundColor
        }
        return cell
    }
}

extension AddWordsByCameraViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isSelected[indexPath.row] = !isSelected[indexPath.row]
        tableView.reloadData()
    }
}
