//
//  TDEditDiaryViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 07/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import RealmSwift

class TDEditDiaryViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var editContainerView: UIView!
    
    // MARK: - Properties
    var tdEditContainerVC = TDEditContainerViewController()
    
    var diary: Diary?
    var section: Int = 0
    var row: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setEditContainer()
        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}


// MARK: - Extensions
// MARK: - Actions
extension TDEditDiaryViewController {
    @IBAction func saveTD(_ sender: Any) {
        guard let destination = RealmController.shared?[section] else {
            return
        }
        
        var title = ""
        if let titleMemo = tdEditContainerVC.tdTitle.text {
            title = titleMemo
        }
        
        let date: Date = tdEditContainerVC.nowDate
        
        let photos = tdEditContainerVC.tdImages
        
        var text = ""
        if let textMemo = tdEditContainerVC.tdMemo.text {
            text = textMemo
        }
        
        var locationText = ""
        if let locationTextMemo = tdEditContainerVC.tdLocation.text {
            locationText = locationTextMemo
        }
        let latitude = tdEditContainerVC.location.latitude
        let longitude = tdEditContainerVC.location.longitude
        
        
        let diary = Diary(title: title, date: date, latitude: latitude, longitude: longitude, text: text, locatonName: locationText, images: photos)
        
        if let row = row {
            
            let willAddPhotos = tdEditContainerVC.willAddPhotos
            let willDeletePhotosPath = tdEditContainerVC.willDeletePhotos
            
            RealmController.changeDiary(row: row, destination: destination, diary: diary, willAddPhotos: willAddPhotos, willDeletePhotosPath: willDeletePhotosPath)
            
        } else {
            
            RealmController.addDiary(destination: destination, diary: diary)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func camera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func album(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - Control ImagePicker
extension TDEditDiaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("imagePickerController1: \(tdEditContainerVC.tdImages.count)")
            tdEditContainerVC.willAddPhotos += [image]
            tdEditContainerVC.tdImages += [image]
            print("imagePickerController2: \(tdEditContainerVC.tdImages.count)")
        }else {
            print("something went wrong")
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Init
extension TDEditDiaryViewController {
    func initData() {
        if let row = row {
            guard let diary = RealmController.shared?[section].diaries[row] else {
                return
            }
            
            tdEditContainerVC.tdTitle.text = diary.title
            tdEditContainerVC.nowDate = diary.date
            tdEditContainerVC.tdMemo.text = diary.text
            tdEditContainerVC.tdLocation.text = diary.locationName
            tdEditContainerVC.location = diary.getLocation()
            tdEditContainerVC.dirPathForPhotos = diary.dirPathForPhotos
            tdEditContainerVC.datePicker.date = tdEditContainerVC.nowDate
            
            if let photos = diary.getPhotos() {
                tdEditContainerVC.tdImages = photos
            }
            
            let images = diary.dirPathForPhotos
            
            for image in images {
                let path = image.dirPath
                tdEditContainerVC.originalPhotos.append(path)
            }
        } else {
            diary = Diary()
            
            guard let shared = RealmController.shared?[section] else {
                return
            }
            
            tdEditContainerVC.nowDate = shared.departureDate
            tdEditContainerVC.datePicker.date = shared.departureDate
        }
    }
    
    func setEditContainer() {
        
        guard let tdEditContainerVC = storyboard?.instantiateViewController(withIdentifier: "TDEditContainerViewController") as? TDEditContainerViewController else {
            return
        }
        addChildViewController(tdEditContainerVC)
        tdEditContainerVC.view.translatesAutoresizingMaskIntoConstraints = false
        editContainerView.addSubview(tdEditContainerVC.view)
        
        NSLayoutConstraint.activate([
            tdEditContainerVC.view.leadingAnchor.constraint(equalTo: editContainerView.leadingAnchor),
            tdEditContainerVC.view.trailingAnchor.constraint(equalTo: editContainerView.trailingAnchor),
            tdEditContainerVC.view.topAnchor.constraint(equalTo: editContainerView.topAnchor),
            tdEditContainerVC.view.bottomAnchor.constraint(equalTo: editContainerView.bottomAnchor)
        ])
    }
}

