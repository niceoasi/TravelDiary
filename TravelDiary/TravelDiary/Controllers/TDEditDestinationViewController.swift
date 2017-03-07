//
//  TDEditDestinationViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 17/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import RealmSwift

protocol TDEditDestinationViewControllerDelegate {
    func didSaveDestination()
}

class TDEditDestinationViewController: UIViewController {
    
    @IBOutlet weak var bottomOfView: NSLayoutConstraint!
    @IBOutlet weak var setView: UIView!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var departureDateButton: UIButton!
    @IBOutlet weak var arrivalDateButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var heightForDatePicker: NSLayoutConstraint!
    @IBOutlet weak var heightForDestinationCollection: NSLayoutConstraint!
    
    var isDepartureDatePicker = false
    var isArriveDatePicker = false
    var destinationButtonClicked = false
    
    let kAnimationDuration = 0.5
    
    var section: Int?
    var destination: Destination?
    var delegate: TDEditDestinationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.destinationButton.layer.borderWidth = 1
        self.destinationButton.layer.cornerRadius = 10
        self.arrivalDateButton.layer.borderWidth = 1
        self.arrivalDateButton.layer.cornerRadius = 10
        self.departureDateButton.layer.borderWidth = 1
        self.departureDateButton.layer.cornerRadius = 10
        
        self.backgroundView.layer.cornerRadius = self.backgroundView.frame.width / 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setEditDestination()
        self.showView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }}

// MARK: - Actions
extension TDEditDestinationViewController {

    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        let destinationText = self.destinationButton.titleLabel?.text
        let departureDateText = self.departureDateButton.titleLabel?.text
        let arrivalDateText = self.arrivalDateButton.titleLabel?.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        
        let departureDate = dateFormatter.date(from: departureDateText!)!
        let arrivalDate = dateFormatter.date(from: arrivalDateText!)!
        
        if departureDate > arrivalDate {
            let alert = UIAlertController(title: "날짜를 수정해 주세요.", message: "도착 날짜와 출발 날짜가 맞지 않습니다.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)

        } else if destinationText == nil {
            let alert = UIAlertController(title: "목적지를 입력해주세요.", message: "목적지를 입력하지 않았습니다.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        } else {
        
            RealmController.addDestination(section: self.section, destinationText: destinationText!, departureDate: departureDate, arrivalDate: arrivalDate)
            
            self.delegate?.didSaveDestination()
            self.hideView()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.hideView()
    }
    
    @IBAction func departureDatePickerButtonTapped() {
        
        if self.destinationButtonClicked {
            self.heightForDestinationCollection.constant = 0
        }
        
        if self.isDepartureDatePicker {
            self.heightForDatePicker.constant = 0
            self.isDepartureDatePicker = false
        } else {
            self.heightForDatePicker.constant = 150
            self.isDepartureDatePicker = true
        }
        self.isArriveDatePicker = false
        self.destinationButtonClicked = false
    }
    
    @IBAction func arrivalDatePickerButtonTapped() {
        
        if self.destinationButtonClicked {
            self.heightForDestinationCollection.constant = 0
        }
        
        if self.isArriveDatePicker {
            self.heightForDatePicker.constant = 0
            self.isArriveDatePicker = false
        } else {
            self.heightForDatePicker.constant = 150
            self.isArriveDatePicker = true
        }
        self.isDepartureDatePicker = false
        self.destinationButtonClicked = false
    }
    
    @IBAction func setDestinationButtonTapped() {
        
        if self.heightForDatePicker.constant != 0 {
            self.heightForDatePicker.constant = 0
        }
        
        if self.destinationButtonClicked {
            self.heightForDestinationCollection.constant = 0
            self.destinationButtonClicked = false
        } else {
            self.heightForDestinationCollection.constant = 100
            self.destinationButtonClicked = true
        }
        self.isDepartureDatePicker = false
        self.isArriveDatePicker = false
    }
    
    @IBAction func didDateChanged(_ sender: UIDatePicker) {
        
        let date = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        
        if self.isDepartureDatePicker {
            let departureDate = dateFormatter.string(from: sender.date)
            self.departureDateButton.setTitle(departureDate, for: .normal)
        }
        if self.isArriveDatePicker {
            let arrivalDate = dateFormatter.string(from: date)
            self.arrivalDateButton.setTitle(arrivalDate, for: .normal)
            
        }
    }
}

// MARK: - CollectionView
extension TDEditDestinationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDDestinationCollectionViewCell", for: indexPath) as! TDDestinationCollectionViewCell
        let region = RegionList(rawValue: indexPath.row)?.convertRegion()
        
        cell.configureCell(region: region!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let region = RegionList(rawValue: indexPath.row)?.convertRegion() {
            self.destinationButton.setTitle(region.region, for: .normal)
            
            self.heightForDestinationCollection.constant = 0
            self.destinationButtonClicked = false
        }
    }
}

// MARK: - Init, Show, Dismis Animation
extension TDEditDestinationViewController {
    func setEditDestination() {
        self.setView.backgroundColor = .white
        self.setView.layer.cornerRadius = 5
        self.setView.layer.masksToBounds = false
        self.setView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.setView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.setView.layer.shadowOpacity = 0.8
        
        self.view.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 0.4)
        
        if let section = section {
            self.destination = RealmController.shared?[section]
            
            self.destinationButton.setTitle(self.destination?.getDestinationName(), for: .normal)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy.MM.dd"
            
            if let departureDate = self.destination?.getDepartureDate() {
                let date = dateFormatter.string(from: departureDate)
                self.departureDateButton.setTitle(date, for: .normal)
            }
            if let arrivalDate = self.destination?.getArrivalDate() {
                let date = dateFormatter.string(from: arrivalDate)
                self.arrivalDateButton.setTitle(date, for: .normal)
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy.MM.dd"
            
            let date = dateFormatter.string(from: Date())
            self.departureDateButton.setTitle(date, for: .normal)
            self.arrivalDateButton.setTitle(date, for: .normal)
        }
    }
    
    internal func showView(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: kAnimationDuration, animations: {
                
                self.bottomOfView.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    internal func hideView() {
        UIView.animate(withDuration: kAnimationDuration, animations: {
            
            self.bottomOfView.constant = -414
            self.view.layoutIfNeeded()
        }, completion: { (flag) in
            self.dismiss(animated: false, completion: nil)
        })

    }
}

