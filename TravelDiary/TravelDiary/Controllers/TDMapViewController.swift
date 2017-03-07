//
//  TDMapViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 10/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift

typealias DiaryWithIndex = (diary: Diary, indexPath: IndexPath)

class TDMapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tdMapView: GMSMapView!
    @IBOutlet weak var showMapTableButton: UIButton!
    
    @IBOutlet weak var mapTableView: UITableView!
    @IBOutlet weak var mapTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewForShowTableButton: UIView!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var zoomLevel: Float = 15.0
    var marker: GMSMarker?
    
    var destinations: Results<Destination>?
    var section: Int?
    var filteredDestination: [Destination] = []
    var diaries = List<Diary>()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showMapTableButton.backgroundColor = .white
        self.showMapTableButton.layer.cornerRadius = 3
        self.showMapTableButton.layer.masksToBounds = false
        self.showMapTableButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.showMapTableButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.showMapTableButton.layer.shadowOpacity = 0.8
        
        self.viewForShowTableButton.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tdMapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
        
        self.tdMapView.isMyLocationEnabled = true
        self.tdMapView.settings.myLocationButton = true
        
        self.destinations = RealmController.filterd
        self.filteredDestination = []
        self.diaries = List<Diary>()
        self.setMarkers()
        self.setZoomButton()
        self.tdMapView.reloadInputViews()
        self.mapTableView.reloadData()
        self.mapTableHeightConstraint.constant = 100
        
        let buttonImage = UIImage(named: "up-arrow")
        self.showMapTableButton.setImage(buttonImage, for: .normal)
    }
}


// MARK: - Extensions
// MARK: - Actions
extension TDMapViewController{
    
    @IBAction func showMapTableButtonTapped(_ sender: Any) {
        self.setMarkers()
        self.mapTableView.reloadData()
        if self.mapTableHeightConstraint.constant == 100 {
            self.mapTableHeightConstraint.constant = 300
            let buttonImage = UIImage(named: "down-arrow")
            self.showMapTableButton.setImage(buttonImage, for: .normal)
        } else {
            self.mapTableHeightConstraint.constant = 100
            let buttonImage = UIImage(named: "up-arrow")
            self.showMapTableButton.setImage(buttonImage, for: .normal)
        }
    }
    
    func zoomInButtonTapped() {
        self.zoomLevel += 1
        self.tdMapView.animate(toZoom: zoomLevel)
    }
    
    func zoomOutButtonTapped() {
        self.zoomLevel -= 1
        self.tdMapView.animate(toZoom: zoomLevel)
    }
    
    @IBAction func changeMapType(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type : ", preferredStyle: .actionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: .default) { (alertAction) in
            self.tdMapView.mapType = kGMSTypeNormal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: .default) { (alertAction) in
            self.tdMapView.mapType = kGMSTypeTerrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: .default) { (alertAction) in
            self.tdMapView.mapType = kGMSTypeHybrid
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - Map Control
extension TDMapViewController: CLLocationManagerDelegate, GMSMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = locations.first?.coordinate.latitude
        let longitude = locations.first?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: zoomLevel)
        
        self.tdMapView.animate(to: camera)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func setMarkers() {
        
        self.tdMapView.clear()
        self.getLocationsForMarkers()
        
        let markerImage = UIImage(named: "street")
        
        for diary in self.diaries {
            let latitude = diary.latitude.value
            let longtitude = diary.longitude.value
            let position = CLLocationCoordinate2D(latitude: latitude!, longitude: longtitude!)
            let marker = GMSMarker(position: position)
            
            marker.title = diary.getTitle()
            marker.tracksViewChanges = true
            marker.icon = markerImage
            marker.map = tdMapView
            
            marker.userData = diary
            
            self.marker = marker
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        UIView.animate(withDuration: 5.0, animations: { () -> Void in
        }, completion: {(finished) in
            self.marker?.tracksViewChanges = false
        })
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let tdDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "TDDetailViewController") as! TDDetailViewController
        let diaryMarker = marker.userData as! Diary
        
        let allDiaries = realm.objects(Diary.self)
        let setdiary = allDiaries.filter("id = \(diaryMarker.id)")
        
        var section = 0
        searchLoop: for destination in self.destinations! {
            for diary in destination.getDiaries() {
                if diary.id == setdiary.first?.id {
                    break searchLoop
                }
            }
            section += 1
        }
        
        var row = 0
        for diary in (self.destinations?[section].getDiaries())! {
            if diary.id == setdiary.first?.id {
                break
            }
            row += 1
        }
        
        let indexPath: IndexPath = IndexPath(row: row, section: section)
        tdDetailVC.indexPath = indexPath
        
        self.navigationController?.pushViewController(tdDetailVC, animated: true)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        let infoWindow = Bundle.main.loadNibNamed("TDMapViewMarkerInfoWindow", owner: self, options: nil)?.first as! TDMapViewMarkerInfoWindow
        
        let diaryMarker = marker.userData as! Diary
        
        infoWindow.bounds.size = CGSize(width: 200, height: 300)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 MM월 dd일"
        
        infoWindow.tdDate.text = dateFormatter.string(from: diaryMarker.getDate())
        infoWindow.tdDate.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 10)
        infoWindow.tdLocation.text = diaryMarker.getLocationName()
        infoWindow.tdLocation.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 10)
        
        if let image = diaryMarker.getPhotos()?.first {
            let size = CGSize(width: 100, height: 100)
            let newImage = UIImage.imageResize(image, size)
            let newImageView = UIImageView(image: newImage)
            newImageView.translatesAutoresizingMaskIntoConstraints = false
            newImageView.layer.cornerRadius = newImageView.frame.width / 2
            newImageView.contentMode = .scaleAspectFill
            newImageView.clipsToBounds = true
            infoWindow.addSubview(newImageView)
            
            let topConstraint = NSLayoutConstraint(item: newImageView, attribute: .top, relatedBy: .equal, toItem: infoWindow, attribute: .top, multiplier: 1, constant: 40)
            let centerConstraint = NSLayoutConstraint(item: newImageView, attribute: .centerX, relatedBy: .equal, toItem: infoWindow, attribute: .centerX, multiplier: 1, constant: 0)
            infoWindow.addConstraints([topConstraint, centerConstraint])
        } else {
            let image = UIImage(named: "noImage.jpg")
            let size = CGSize(width: 100, height: 100)
            let newImage = UIImage.imageResize(image!, size)
            let newImageView = UIImageView(image: newImage)
            newImageView.translatesAutoresizingMaskIntoConstraints = false
            newImageView.layer.cornerRadius = newImageView.frame.width / 2
            newImageView.contentMode = .scaleAspectFill
            newImageView.clipsToBounds = true
            infoWindow.addSubview(newImageView)
            
            let topConstraint = NSLayoutConstraint(item: newImageView, attribute: .top, relatedBy: .equal, toItem: infoWindow, attribute: .top, multiplier: 1, constant: 40)
            let centerConstraint = NSLayoutConstraint(item: newImageView, attribute: .centerX, relatedBy: .equal, toItem: infoWindow, attribute: .centerX, multiplier: 1, constant: 0)
            infoWindow.addConstraints([topConstraint, centerConstraint])
        }
        
        return infoWindow
    }
}

// MARK: - TableView
extension TDMapViewController: UITableViewDelegate, UITableViewDataSource, TDMapTableViewCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.section != nil {
            return 1
        } else {
            var count = 0
            if let destinations = self.destinations {
                for destination in destinations {
                    var flag = false
                    let diaries = List<Diary>()
                    for diary in destination.getDiaries() {
                        if diary.latitude.value != nil {
                            flag = true
                            diaries.append(diary)
                        }
                    }
                    if flag {
                        count += 1
                        let setDestination = destination
                        setDestination.setDiaries(diaries: diaries)
                        self.filteredDestination += [setDestination]
                    }
                }
                return count
            }
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableCell(withIdentifier: "TDMapTableHeaderViewCell") as! TDMapTableHeaderViewCell
        
        if let getSection = self.section {
            let destination = self.destinations![getSection]
            headerView.destinationName.text = destination.getDestinationName()
        } else {
            let destination = self.filteredDestination[section]
            headerView.destinationName.text = destination.getDestinationName()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.section != nil {
            return self.diaries.count
        } else {
            let count = self.filteredDestination[section].getDirayCount()
            
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TDMapTableViewCell", for: indexPath) as! TDMapTableViewCell
        cell.delegate = self
        
        if self.section != nil {
            let diary = self.diaries[indexPath.row]
            cell.configureCell(diary: diary)
        } else {
            let diary = self.filteredDestination[indexPath.section].getDiary(at: indexPath.row)
            cell.configureCell(diary: diary!)
        }
        
        return cell
    }
    
    func mapTableTapped(diary: Diary) {
        
        let latitude = diary.latitude.value
        let longitude = diary.longitude.value
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: zoomLevel)
        
        self.tdMapView.animate(to: camera)
    }
    
    func showMapTable(isShown: Bool) -> Bool {
        var checkShown = false
        
        if isShown == false {
            self.mapTableHeightConstraint.constant = 300
            checkShown = true
        } else {
            self.mapTableHeightConstraint.constant = 100
            checkShown = false
        }
        
        return checkShown
    }
}

// MARK: - Setting
extension TDMapViewController {
    
    func getLocationsForMarkers() {
        
        if let section = self.section {
            let destination = self.destinations?[section]
            if let diaries = destination?.getDiaries() {
                let setDiaries = diaries.filter({ (diary) -> Bool in
                    return diary.latitude.value != nil
                })
                
                for diary in setDiaries {
                    self.diaries.append(diary)
                }
            }
        } else {
            for destination in self.destinations! {
                let setDiaries = destination.getDiaries().filter({ (diary) -> Bool in
                    return diary.latitude.value != nil
                })
                
                for diary in setDiaries {
                    self.diaries.append(diary)
                }
            }
        }
    }
    
    func setZoomButton() {
        let zoomOutButton = UIButton(frame: CGRect())
        let zoomOutImage = UIImage(named: "zoom-out")
        zoomOutButton.setImage(zoomOutImage, for: .normal)
        zoomOutButton.setTitleColor(UIColor.blue, for: .normal)
        zoomOutButton.backgroundColor = .clear
        zoomOutButton.addTarget(self, action: #selector(zoomOutButtonTapped), for: .touchUpInside)
        
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        let zoomOutHeight = NSLayoutConstraint(item: zoomOutButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let zoomOutWidth = NSLayoutConstraint(item: zoomOutButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let zoomOutHorizontalConstraint = NSLayoutConstraint(item: zoomOutButton, attribute: .trailing, relatedBy: .equal, toItem: self.tdMapView, attribute: .trailing, multiplier: 1, constant: -10)
        let zoomOutVerticalConstraint = NSLayoutConstraint(item: zoomOutButton, attribute: .top, relatedBy: .equal, toItem: self.tdMapView, attribute: .top, multiplier: 1, constant: 10)
        
        self.tdMapView.insertSubview(zoomOutButton, aboveSubview: self.tdMapView)
        self.tdMapView.addConstraints([zoomOutWidth, zoomOutHeight, zoomOutVerticalConstraint, zoomOutHorizontalConstraint])
        
        let zoomInButton = UIButton(frame: CGRect())
        let zoomInImage = UIImage(named: "zoom-in")
        zoomInButton.setImage(zoomInImage, for: .normal)
        zoomInButton.setTitleColor(UIColor.blue, for: .normal)
        zoomInButton.backgroundColor = .clear
        zoomInButton.addTarget(self, action: #selector(zoomInButtonTapped), for: .touchUpInside)
        
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        
        let zoomInHeight = NSLayoutConstraint(item: zoomInButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let zoomInWidth = NSLayoutConstraint(item: zoomInButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let zoomInHorizontalConstraint = NSLayoutConstraint(item: zoomInButton, attribute: .trailing, relatedBy: .equal, toItem: zoomOutButton, attribute: .leading, multiplier: 1, constant: -10)
        let zoomInVerticalConstraint = NSLayoutConstraint(item: zoomInButton, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: self.tdMapView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
        
        self.tdMapView.insertSubview(zoomInButton, aboveSubview: self.tdMapView)
        self.tdMapView.addConstraints([zoomInHeight, zoomInWidth, zoomInHorizontalConstraint, zoomInVerticalConstraint])
    }
}

