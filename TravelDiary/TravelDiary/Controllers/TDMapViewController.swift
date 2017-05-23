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
    var currentLocation: CLLocation?
    var zoomLevel: Float = 15.0
    var marker: GMSMarker?
    
    var destinations: Results<Destination>?
    var section: Int?
    var filteredDestination: [Destination] = []
    var diaries = List<Diary>()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showMapTableButton.backgroundColor = .white
        showMapTableButton.layer.cornerRadius = 3
        showMapTableButton.layer.masksToBounds = false
        showMapTableButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        showMapTableButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        showMapTableButton.layer.shadowOpacity = 0.8
        
        viewForShowTableButton.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tdMapView?.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
        
        tdMapView.isMyLocationEnabled = true
        tdMapView.settings.myLocationButton = true
        
        destinations = RealmController.filterd
        filteredDestination = []
        diaries = List<Diary>()
        setMarkers()
        setZoomButton()
        tdMapView.reloadInputViews()
        mapTableView.reloadData()
        mapTableHeightConstraint.constant = 100
        
        let buttonImage = UIImage(named: "up-arrow")
        showMapTableButton.setImage(buttonImage, for: .normal)
    }
}


// MARK: - Extensions
// MARK: - Actions
extension TDMapViewController{
    
    @IBAction func showMapTableButtonTapped(_ sender: Any) {
        setMarkers()
        mapTableView.reloadData()
        if mapTableHeightConstraint.constant == 100 {
            mapTableHeightConstraint.constant = 300
            let buttonImage = UIImage(named: "down-arrow")
            showMapTableButton.setImage(buttonImage, for: .normal)
        } else {
            mapTableHeightConstraint.constant = 100
            let buttonImage = UIImage(named: "up-arrow")
            showMapTableButton.setImage(buttonImage, for: .normal)
        }
    }
    
    func zoomInButtonTapped() {
        zoomLevel += 1
        tdMapView.animate(toZoom: zoomLevel)
    }
    
    func zoomOutButtonTapped() {
        zoomLevel -= 1
        tdMapView.animate(toZoom: zoomLevel)
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
        
        guard let latitude = locations.first?.coordinate.latitude else {
            return
        }
        guard let longitude = locations.first?.coordinate.longitude else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomLevel)
        
        tdMapView.animate(to: camera)
        
        locationManager.stopUpdatingLocation()
    }
    
    func setMarkers() {
        
        tdMapView.clear()
        getLocationsForMarkers()
        
        let markerImage = UIImage(named: "street")
        
        for diary in diaries {
            var position = CLLocationCoordinate2D()
            if let latitude = diary.latitude.value, let longtitude = diary.longitude.value {
                position = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
            }
            let marker = GMSMarker(position: position)
            
            marker.title = diary.title
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
        guard let tdDetailVC = storyboard?.instantiateViewController(withIdentifier: "TDDetailViewController") as? TDDetailViewController else {
            return
        }
        let diaryMarker = marker.userData as? Diary
        
        let allDiaries = realm.objects(Diary.self)
        let setdiary = allDiaries.filter("id = \(String(describing: diaryMarker?.id))")
        
        guard let destinations = self.destinations else {
            return
        }
        
        var section = 0
        searchLoop: for destination in destinations {
            for diary in destination.diaries {
                if diary.id == setdiary.first?.id {
                    break searchLoop
                }
            }
            section += 1
        }
        
        var row = 0
        for diary in (destinations[section].diaries) {
            if diary.id == setdiary.first?.id {
                break
            }
            row += 1
        }
        
        let indexPath: IndexPath = IndexPath(row: row, section: section)
        tdDetailVC.indexPath = indexPath
        
        navigationController?.pushViewController(tdDetailVC, animated: true)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        guard let infoWindow = Bundle.main.loadNibNamed("TDMapViewMarkerInfoWindow", owner: self, options: nil)?.first as? TDMapViewMarkerInfoWindow else {
            return nil
        }
        
        let diaryMarker = marker.userData as? Diary
        
        infoWindow.bounds.size = CGSize(width: 200, height: 300)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 MM월 dd일"
        if let date = diaryMarker?.date {
            infoWindow.tdDate.text = dateFormatter.string(from: date)
        }
        infoWindow.tdDate.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 10)
        infoWindow.tdLocation.text = diaryMarker?.locationName
        infoWindow.tdLocation.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 10)
        
        if let image = diaryMarker?.getPhotos()?.first {
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
            var newImage = UIImage()
            let size = CGSize(width: 100, height: 100)
            if let image = UIImage(named: "noImage.jpg") {
                newImage = UIImage.imageResize(image, size)
            }
            
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
        if section != nil {
            return 1
        } else {
            var count = 0
            if let destinations = destinations {
                for destination in destinations {
                    var flag = false
                    let diaries = List<Diary>()
                    for diary in destination.diaries {
                        if diary.latitude.value != nil {
                            flag = true
                            diaries.append(diary)
                        }
                    }
                    if flag {
                        count += 1
                        let setDestination = destination
                        setDestination.diaries = diaries
                        filteredDestination += [setDestination]
                    }
                }
                return count
            }
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableCell(withIdentifier: "TDMapTableHeaderViewCell") as? TDMapTableHeaderViewCell
        
        if let getSection = self.section {
            let destination = destinations?[getSection]
            headerView?.destinationName.text = destination?.destinationName
        } else {
            let destination = filteredDestination[section]
            headerView?.destinationName.text = destination.destinationName
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
            return diaries.count
        } else {
            let count = filteredDestination[section].diaries.count
            
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dummyCell = TDMapTableViewCell()
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TDMapTableViewCell", for: indexPath) as? TDMapTableViewCell else {
            return dummyCell
        }
        
        cell.delegate = self
        
        if section != nil {
            let diary = diaries[indexPath.row]
            cell.configureCell(diary: diary)
        } else {
            let diary = filteredDestination[indexPath.section].diaries[indexPath.row]
            cell.configureCell(diary: diary)
        }
        
        return cell
    }
    
    func mapTableTapped(diary: Diary) {
        
        guard let latitude = diary.latitude.value, let longitude = diary.longitude.value else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomLevel)
        
        tdMapView.animate(to: camera)
    }
    
    func showMapTable(isShown: Bool) -> Bool {
        var checkShown = false
        
        if isShown == false {
            mapTableHeightConstraint.constant = 300
            checkShown = true
        } else {
            mapTableHeightConstraint.constant = 100
            checkShown = false
        }
        
        return checkShown
    }
}

// MARK: - Setting
extension TDMapViewController {
    
    func getLocationsForMarkers() {
        
        if let section = section {
            let destination = destinations?[section]
            if let diaries = destination?.diaries {
                let setDiaries = diaries.filter({ (diary) -> Bool in
                    return diary.latitude.value != nil
                })
                
                for diary in setDiaries {
                    diaries.append(diary)
                }
            }
        } else {
            guard let row = destinations else {
                return
            }
            for destination in row {
                let setDiaries = destination.diaries.filter({ (diary) -> Bool in
                    return diary.latitude.value != nil
                })
                
                for diary in setDiaries {
                    diaries.append(diary)
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
        let zoomOutHorizontalConstraint = NSLayoutConstraint(item: zoomOutButton, attribute: .trailing, relatedBy: .equal, toItem: tdMapView, attribute: .trailing, multiplier: 1, constant: -10)
        let zoomOutVerticalConstraint = NSLayoutConstraint(item: zoomOutButton, attribute: .top, relatedBy: .equal, toItem: tdMapView, attribute: .top, multiplier: 1, constant: 10)
        
        tdMapView.insertSubview(zoomOutButton, aboveSubview: tdMapView)
        tdMapView.addConstraints([zoomOutWidth, zoomOutHeight, zoomOutVerticalConstraint, zoomOutHorizontalConstraint])
        
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
        let zoomInVerticalConstraint = NSLayoutConstraint(item: zoomInButton, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: tdMapView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
        
        tdMapView.insertSubview(zoomInButton, aboveSubview: tdMapView)
        tdMapView.addConstraints([zoomInHeight, zoomInWidth, zoomInHorizontalConstraint, zoomInVerticalConstraint])
    }
}

