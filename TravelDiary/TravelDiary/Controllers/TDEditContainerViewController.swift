//
//  TDEditContainerViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 18/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import RealmSwift

struct Typealiases {
    typealias JSONDict = [String:Any]
}

class TDEditContainerViewController: UITableViewController {
    
    @IBOutlet weak var tdTableView: UITableView!
    @IBOutlet weak var tdCollectionView: UICollectionView!
    @IBOutlet weak var tdTitle: UITextField!
    @IBOutlet weak var tdDate: UITextField!
    @IBOutlet weak var tdLocation: UITextField!
    @IBOutlet weak var tdMemo: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Set for UI
    @IBOutlet var uiContentViewCollection: [UIView]!
    @IBOutlet var uiCardViewViewCollection: [UIView]!
    @IBOutlet weak var backgroundViewForCollectionView: UIView!
    // Set for UI
    
    let locationManager = CLLocationManager()
    
    var nowDate = Date()
    var flagForLocation: Bool = false
    var location: (latitude: Double?, longitude: Double?)
    var dirPathForPhotos = List<DirPathForImage>()
    var tdImages = [UIImage]()
    var isDatePickeHidden = true
    
    var originalPhotos: [String] = []
    var willDeletePhotos: [String] = []
    var willAddPhotos: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tdCollectionView.register(UINib(nibName: "TDImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TDImageCollectionViewCell")
        
        tdTitle.delegate = self
        tdDate.delegate = self
        tdLocation.delegate = self
        tdMemo.delegate = self
        locationManager.delegate = self
        setTableUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 MM월 dd일"
        
        tdDate.text = dateFormatter.string(from: nowDate)
        
        tdTableView.reloadData()
        tdCollectionView.reloadData()
    }
}

// MARK: - Actions
extension TDEditContainerViewController {
    @IBAction func editDateButtonTapped(_ sender: Any) {
        
        if isDatePickeHidden {
            isDatePickeHidden = false
            datePicker.isHidden = false
            
            tdTableView.reloadData()
        } else {
            isDatePickeHidden = true
            datePicker.isHidden = true
            
            nowDate = datePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy년 MM월 dd일"
            
            tdDate.text = dateFormatter.string(from: nowDate)
            
            tdTableView.reloadData()
        }
    }
    
    @IBAction func editLocationButtonTapped(_ sender: Any) {
        guard let searchMapVC = storyboard?.instantiateViewController(withIdentifier: "TDSearchMapViewController") as? TDSearchMapViewController else {
            return
        }
        searchMapVC.delegate = self
        
        present(searchMapVC, animated: true, completion: nil)
    }
    
    @IBAction func setCurrentLocationButtonTapped(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        flagForLocation = false
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 MM월 dd일"
        
        tdDate.text = dateFormatter.string(from: sender.date)
    }
}

// MARK: - TDSearchMapViewControllerDelegate
extension TDEditContainerViewController: TDSearchMapViewControllerDelegate {
    func changeLocation(location: CLLocationCoordinate2D, locationName: String) {
        flagForLocation = true
        self.location = (latitude: location.latitude, longitude: location.longitude)
        tdLocation.text = locationName
        
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - TableView
extension TDEditContainerViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 && isDatePickeHidden {
            return 0
        } else if indexPath.row == 4 && tdImages.count == 0 {
            return 0
        } else {
            return super.tableView(tdTableView, heightForRowAt : indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            tdCollectionView.reloadData()
        }
    }
    
    func setTableUI() {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: tdMemo.frame.width, height: 50))
        let resignButton = UIButton(frame: CGRect(x: tdMemo.frame.width - 50, y: 0, width: 50, height: 50))
        let image = UIImage(named: "resignKeyboard")
        resignButton.setImage(image, for: .normal)
        
        resignButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        resignButton.backgroundColor = .white
        accessoryView.addSubview(resignButton)
        accessoryView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
        
        tdMemo.inputAccessoryView = accessoryView
        tdTitle.inputAccessoryView = accessoryView
        
        for cardView in uiCardViewViewCollection {
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 3
            cardView.layer.masksToBounds = false
            cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
            cardView.layer.shadowOpacity = 0.8
        }
        
        for contentView in uiContentViewCollection {
            contentView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
        }

        backgroundViewForCollectionView.backgroundColor = .black
    }
}

// MARK: - CollectionView
extension TDEditContainerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return tdImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dummyCell = TDImageCollectionViewCell()
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDImageCollectionViewCell", for: indexPath) as? TDImageCollectionViewCell else {
            return dummyCell
        }
        
        let tdImage = tdImages[indexPath.row]
        cell.configureCell(tdImage: tdImage, isClipTrue: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let alertAction = UIAlertController(title: "사진을 삭제 하시겠습니까?", message: nil, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "예", style: .default) { (alertAction) in
            
            if indexPath.row > self.originalPhotos.count - 1 {
            } else {
                let path = self.originalPhotos[indexPath.row]
                self.originalPhotos.remove(at: indexPath.row)
                self.willDeletePhotos.append(path)
            }
            self.tdImages.remove(at: indexPath.row)
            self.tdCollectionView.deleteItems(at: [indexPath])
            
            self.tdTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertAction.addAction(okayAction)
        alertAction.addAction(cancelAction)
        
        present(alertAction, animated: true, completion: nil)
    }
}

// MARK: - Get Current Location
extension TDEditContainerViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count == 1 {
            guard let location = manager.location else {
                return
            }
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if let error = error {
                    print("Reverse geocoder failed with error" + error.localizedDescription)
                    return
                }
                guard let markers = placemarks else {
                    return
                }
                if markers.isEmpty {
                    if let pm = placemarks?.first {
                        if !self.flagForLocation {
                            self.setLocationInfo(placemark: pm)
                        }
                    }
                } else {
                    print("Problem with the data received from geocoder, \(String(describing: placemarks?.count))")
                }
            })
        }
    }
    
    func setLocationInfo(placemark: CLPlacemark) {
        let location = placemark.location?.coordinate
        self.location = (latitude: (location?.latitude), longitude: (location?.longitude))
        locationManager.stopUpdatingLocation()
        
        var locationName = ""
        if let locatlity = placemark.locality {
            locationName += "\(locatlity)"
        }
        if let thoroughfare = placemark.thoroughfare {
            locationName += "\(thoroughfare)"
        }
        
        tdLocation.text = locationName
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
}

// MARK: - Control Keyboard
extension TDEditContainerViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func handleTap() {
        if tdTitle.isFirstResponder {
            tdTitle.resignFirstResponder()
        }
        
        if tdMemo.isFirstResponder {
            tdMemo.resignFirstResponder()
        }
    }
}
