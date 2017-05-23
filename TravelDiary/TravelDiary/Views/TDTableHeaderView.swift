//
//  TDTableHeaderView.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 26/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
protocol TDHeaderViewDelegate: class {
    func collapseCell(section: Int)
    func newDiaryFor(section: Int)
    func editDestinationFor(section: Int)
    func deleteDestinationFor(section: Int)
    func showMapFor(section: Int)
    func moreButtonTapped(alertVC: UIAlertController)
}

class TDTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var departureDateLabel: UILabel!
    @IBOutlet weak var arrivalDateLable: UILabel!
    @IBOutlet weak var showCellButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var backgroundCardView: UIView!
    
    @IBOutlet weak var headerContentView: UIView!
    
    weak var delegate: TDHeaderViewDelegate?
    var section: Int = 0
    var isMoreButtonClicked: Bool = false
    var destination: Destination?
    var photos: [UIImage] = []
    
}

// MARK: - Actions
extension TDTableHeaderView {
    
    func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? TDTableHeaderView else {
            return
        }
        
        delegate?.collapseCell(section: cell.section)
    }
    
    @IBAction func moreButtonTapped() {
        let alertVC = UIAlertController(title: "더 보기", message: nil, preferredStyle: .actionSheet)
        let editDestinationButton = UIAlertAction(title: "Edit Destination", style: .default) { (action) in
            self.delegate?.editDestinationFor(section: self.section)
        }
        let newDiaryButton = UIAlertAction(title: "New Diary", style: .default) { (action) in
            self.delegate?.newDiaryFor(section: self.section)
        }
        let deleteDestinationButton = UIAlertAction(title: "Delete Destination", style: .default) { (action) in
            self.delegate?.deleteDestinationFor(section: self.section)
        }
        let showMapButton = UIAlertAction(title: "Show Map", style: .default) { (action) in
            self.delegate?.showMapFor(section: self.section)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertVC.addAction(editDestinationButton)
        alertVC.addAction(newDiaryButton)
        alertVC.addAction(deleteDestinationButton)
        alertVC.addAction(showMapButton)
        alertVC.addAction(cancelButton)
        
        delegate?.moreButtonTapped(alertVC: alertVC)
    }
}

// Header Setting
// MARK: - Configure
extension TDTableHeaderView {
    func configureView(destination: Destination, section: Int, state: Bool) {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHeader(_:))))
        
        self.section = section
        self.destination = destination
        let destinationName = destination.destinationName
        let departureDate = destination.departureDate
        let arrivalDate = destination.arrivalDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        
        destinationLabel?.text = destinationName
        departureDateLabel?.text = dateFormatter.string(from: departureDate)
        arrivalDateLable?.text = dateFormatter.string(from: arrivalDate)
        
        setShowCellButton(state: state)
        setUI()
    }
    
    func setShowCellButton(state: Bool) {
        if !state {
            let image = UIImage(named: "caret-down")
            showCellButton?.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "caret-arrow-up")
            showCellButton?.setImage(image, for: .normal)
        }
    }
    
    func setUI() {
        for rawValue in 0...6 {
            let region = RegionList(rawValue: rawValue)?.convertRegion().region
            let color = RegionList(rawValue: rawValue)?.convertRegion().color
            if let name = destination?.destinationName {
                if region == name {
                    backgroundCardView.backgroundColor = color
                }
            }
        }
        
        backgroundCardView.layer.cornerRadius = 3
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8
        
        headerContentView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
        
        moreButton.layer.cornerRadius = 4
        showCellButton.layer.cornerRadius = 4
    }
}
