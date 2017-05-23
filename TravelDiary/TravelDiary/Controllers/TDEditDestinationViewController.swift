//
//  TDEditDestinationViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 17/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import RealmSwift

protocol TDEditDestinationViewControllerDelegate: class {
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
    weak var delegate: TDEditDestinationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        destinationButton.layer.borderWidth = 1
        destinationButton.layer.cornerRadius = 10
        arrivalDateButton.layer.borderWidth = 1
        arrivalDateButton.layer.cornerRadius = 10
        departureDateButton.layer.borderWidth = 1
        departureDateButton.layer.cornerRadius = 10
        
        backgroundView.layer.cornerRadius = backgroundView.frame.width / 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setEditDestination()
        showView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }}

// MARK: - Actions
extension TDEditDestinationViewController {

    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        guard let destinationText = destinationButton.titleLabel?.text else {
            let alert = UIAlertController(title: "목적지를 입력해주세요.", message: "목적지를 입력하지 않았습니다.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
            return
        }
        guard let departureDateText = departureDateButton.titleLabel?.text else {
            return
        }
        guard let arrivalDateText = arrivalDateButton.titleLabel?.text else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        
        guard let departureDate = dateFormatter.date(from: departureDateText) else {
            return
        }
        guard let arrivalDate = dateFormatter.date(from: arrivalDateText) else {
            return
        }
        
        if departureDate > arrivalDate {
            let alert = UIAlertController(title: "날짜를 수정해 주세요.", message: "도착 날짜와 출발 날짜가 맞지 않습니다.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)

        } else {
        
            RealmController.addDestination(section: section, destinationText: destinationText, departureDate: departureDate, arrivalDate: arrivalDate)
            
            delegate?.didSaveDestination()
            hideView()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        hideView()
    }
    
    @IBAction func departureDatePickerButtonTapped() {
        
        if destinationButtonClicked {
            heightForDestinationCollection.constant = 0
        }
        
        if isDepartureDatePicker {
            heightForDatePicker.constant = 0
            isDepartureDatePicker = false
        } else {
            heightForDatePicker.constant = 150
            isDepartureDatePicker = true
        }
        isArriveDatePicker = false
        destinationButtonClicked = false
    }
    
    @IBAction func arrivalDatePickerButtonTapped() {
        
        if destinationButtonClicked {
            heightForDestinationCollection.constant = 0
        }
        
        if isArriveDatePicker {
            heightForDatePicker.constant = 0
            isArriveDatePicker = false
        } else {
            heightForDatePicker.constant = 150
            isArriveDatePicker = true
        }
        isDepartureDatePicker = false
        destinationButtonClicked = false
    }
    
    @IBAction func setDestinationButtonTapped() {
        
        if heightForDatePicker.constant != 0 {
            heightForDatePicker.constant = 0
        }
        
        if destinationButtonClicked {
            heightForDestinationCollection.constant = 0
            destinationButtonClicked = false
        } else {
            heightForDestinationCollection.constant = 100
            destinationButtonClicked = true
        }
        isDepartureDatePicker = false
        isArriveDatePicker = false
    }
    
    @IBAction func didDateChanged(_ sender: UIDatePicker) {
        
        let date = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        
        if isDepartureDatePicker {
            let departureDate = dateFormatter.string(from: sender.date)
            departureDateButton.setTitle(departureDate, for: .normal)
        }
        if isArriveDatePicker {
            let arrivalDate = dateFormatter.string(from: date)
            arrivalDateButton.setTitle(arrivalDate, for: .normal)
            
        }
    }
}

// MARK: - CollectionView
extension TDEditDestinationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dummyCell = TDDestinationCollectionViewCell()
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDDestinationCollectionViewCell", for: indexPath) as? TDDestinationCollectionViewCell else {
            return dummyCell
        }
        if let region = RegionList(rawValue: indexPath.row)?.convertRegion() {
            cell.configureCell(region: region)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let region = RegionList(rawValue: indexPath.row)?.convertRegion() {
            destinationButton.setTitle(region.region, for: .normal)
            
            heightForDestinationCollection.constant = 0
            destinationButtonClicked = false
        }
    }
}

// MARK: - Init, Show, Dismis Animation
extension TDEditDestinationViewController {
    func setEditDestination() {
        setView.backgroundColor = .white
        setView.layer.cornerRadius = 5
        setView.layer.masksToBounds = false
        setView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        setView.layer.shadowOffset = CGSize(width: 0, height: 0)
        setView.layer.shadowOpacity = 0.8
        
        view.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 0.4)
        
        if let section = section {
            destination = RealmController.shared?[section]
            
            destinationButton.setTitle(destination?.destinationName, for: .normal)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy.MM.dd"
            
            if let departureDate = destination?.departureDate {
                let date = dateFormatter.string(from: departureDate)
                departureDateButton.setTitle(date, for: .normal)
            }
            if let arrivalDate = destination?.arrivalDate {
                let date = dateFormatter.string(from: arrivalDate)
                arrivalDateButton.setTitle(date, for: .normal)
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy.MM.dd"
            
            let date = dateFormatter.string(from: Date())
            departureDateButton.setTitle(date, for: .normal)
            arrivalDateButton.setTitle(date, for: .normal)
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

