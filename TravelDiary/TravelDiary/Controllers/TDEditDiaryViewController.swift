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
    var tdEditContainerVC: TDEditContainerViewController!
    
    var diary: Diary!
    var section: Int!
    var row: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setEditContainer()
        self.initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}


// MARK: - Extensions
// MARK: - Actions
extension TDEditDiaryViewController {
    @IBAction func saveTD(_ sender: Any) {
        let title = self.tdEditContainerVC.tdTitle.text
        let date: Date = self.tdEditContainerVC.nowDate
        
        let photos = self.tdEditContainerVC.tdImages
        
        let text = self.tdEditContainerVC.tdMemo.text
        let locationText = self.tdEditContainerVC.tdLocation.text
        let latitude = self.tdEditContainerVC.location.latitude
        let longitude = self.tdEditContainerVC.location.longitude
        
        let realm = try! Realm()
        let destination = RealmController.shared[self.section]
        
        let diary = Diary(title: title, date: date, latitude: latitude, longitude: longitude, text: text, locatonName: locationText, images: photos)
        
        if let row = self.row {
            
            let willAddPhotos = self.tdEditContainerVC.willAddPhotos
            let willDeletePhotosPath = self.tdEditContainerVC.willDeletePhotos
            
            RealmController.changeDiary(row: row, destination: destination, diary: diary, willAddPhotos: willAddPhotos, willDeletePhotosPath: willDeletePhotosPath)
            
        } else {
            
            RealmController.addDiary(destination: destination, diary: diary)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func camera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func album(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - Control ImagePicker
extension TDEditDiaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("imagePickerController1: \(tdEditContainerVC.tdImages.count)")
            self.tdEditContainerVC.willAddPhotos += [image]
            self.tdEditContainerVC.tdImages += [image]
            print("imagePickerController2: \(tdEditContainerVC.tdImages.count)")
        }else {
            print("something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Init
extension TDEditDiaryViewController {
    func initData() {
        if let row = self.row {
            self.diary = RealmController.shared[section].getDiary(at: row)
            
            self.tdEditContainerVC.tdTitle.text = self.diary?.getTitle()
            self.tdEditContainerVC.nowDate = (self.diary?.getDate())!
            self.tdEditContainerVC.tdMemo.text = self.diary?.getText()
            self.tdEditContainerVC.tdLocation.text = self.diary?.getLocationName()
            self.tdEditContainerVC.location = diary.getLocation()
            self.tdEditContainerVC.dirPathForPhotos = diary.dirPathForPhotos
            self.tdEditContainerVC.datePicker.date = self.tdEditContainerVC.nowDate
            
            if let photos = diary?.getPhotos() {
                self.tdEditContainerVC.tdImages = photos
                
                for image in diary.dirPathForPhotos {
                    if let path = image.dirPath {
                        self.tdEditContainerVC.originalPhotos.append(path)
                    }
                }
            }
        } else {
            self.diary = Diary()
            
            self.tdEditContainerVC.nowDate = RealmController.shared[section].departureDate
            self.tdEditContainerVC.datePicker.date = RealmController.shared[section].departureDate
        }
    }
    
    func setEditContainer() {
        
        self.tdEditContainerVC = storyboard!.instantiateViewController(withIdentifier: "TDEditContainerViewController") as! TDEditContainerViewController
        addChildViewController(self.tdEditContainerVC)
        self.tdEditContainerVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.editContainerView.addSubview(self.tdEditContainerVC.view)
        
        NSLayoutConstraint.activate([
            self.tdEditContainerVC.view.leadingAnchor.constraint(equalTo: self.editContainerView.leadingAnchor),
            self.tdEditContainerVC.view.trailingAnchor.constraint(equalTo: self.editContainerView.trailingAnchor),
            self.tdEditContainerVC.view.topAnchor.constraint(equalTo: self.editContainerView.topAnchor),
            self.tdEditContainerVC.view.bottomAnchor.constraint(equalTo: self.editContainerView.bottomAnchor)
            ])
    }
}

