//
//  TDSearchMapViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 21/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol TDSearchMapViewControllerDelegate {
    func changeLocation(location: CLLocationCoordinate2D, locationName: String)
}

class TDSearchMapViewController: UIViewController {

    @IBOutlet weak var tdMapView: GMSMapView!
    
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var buttonCardView: UIView!
    
    var locationManager = CLLocationManager()
    var location: CLLocationCoordinate2D!
    var locationName: String = ""
    var zoomLevel: Float = 15
    
    var delegate: TDSearchMapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        self.setButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

// MARK: - Action
extension TDSearchMapViewController {
    @IBAction func openSearchPlace() {
        let autoCompliteVC = GMSAutocompleteViewController()
        autoCompliteVC.delegate = self
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompliteVC, animated: true, completion: nil)
    }
    
    @IBAction func saveLocationButtonTapped(_ sender: Any) {
        self.delegate?.changeLocation(location: self.location, locationName: self.locationName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func zoomInButtonTapped() {
        self.zoomLevel += 1
        self.tdMapView.animate(toZoom: zoomLevel)
    }
    
    func zoomOutButtonTapped() {
        self.zoomLevel -= 1
        self.tdMapView.animate(toZoom: zoomLevel)
    }
}

// MARK: - CLLocation Manager Delegate
extension TDSearchMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: self.zoomLevel)
        
        self.tdMapView.animate(to: camera)
        
        self.locationManager.stopUpdatingLocation()
    }
}

// MARK: - GMSMapView Delegate
extension TDSearchMapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.tdMapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.tdMapView.isMyLocationEnabled = true
        if gesture {
            mapView.selectedMarker = nil
        }
    }
}

// MARK: - GMSAutocompleteViewControllerDelegate
extension TDSearchMapViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: self.zoomLevel)
        self.locationManager.stopUpdatingLocation()
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.title = "\(place.name)"
        marker.snippet = "\((place.formattedAddress)!)"
        marker.map = self.tdMapView
        
        print("\(place.coordinate.latitude) :: \(place.coordinate.longitude)")
        self.location = place.coordinate
        self.locationName = place.name
        
        self.tdMapView.animate(to: camera)
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error Auto Complete: \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Set Button
extension TDSearchMapViewController {
    
    func setButton() {
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
        
        self.buttonCardView.backgroundColor = .white
        self.buttonCardView.layer.cornerRadius = 3
        self.buttonCardView.layer.masksToBounds = false
        self.buttonCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.buttonCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.buttonCardView.layer.shadowOpacity = 0.8
        self.buttonContainerView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }
}

