//
//  TDTableViewCell.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 07/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

class TDTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var tdImageView: UIImageView!
    @IBOutlet weak var tdDate: UILabel!
    @IBOutlet weak var tdWeakday: UILabel!
    @IBOutlet weak var tdLocation: UILabel!
    @IBOutlet weak var tdMemo: UILabel!
    
    @IBOutlet weak var widthForimageView: NSLayoutConstraint!
    @IBOutlet weak var backgroundCardView: UIView!
    
    // MARK: - Properties
    var diary: Diary!
    var collasped = false
    
    // Initialization code
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// Setting
// MARK: - Configure
extension TDTableViewCell {
    
    func setUI() {
        
        self.tdDate.layer.borderColor = UIColor.blue.cgColor
        self.tdDate.layer.borderWidth = 1
        
        self.tdImageView?.layer.cornerRadius = (tdImageView?.frame.width)! / 2
        self.tdImageView?.layer.borderColor = UIColor.white.cgColor
        self.tdImageView?.layer.borderWidth = 1
        
        self.backgroundCardView.backgroundColor = .white
        self.backgroundCardView.layer.cornerRadius = 3
        self.backgroundCardView.layer.masksToBounds = false
        self.backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backgroundCardView.layer.shadowOpacity = 0.8
        
        self.contentView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }
    
    func configureCell(diary: Diary) {
        self.diary = diary
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd일"
        
        let date = self.diary.getDate()
        self.tdDate.text = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "EEEE"
        
        self.tdWeakday.text = dateFormatter.string(from: date)
        
        self.tdMemo.text = self.diary.getText()
        
        if let locationName = self.diary.getLocationName() {
            self.tdLocation.text = locationName
        }
        
        if let tdImage = self.diary.getPhotos() {
            self.tdImageView.image = tdImage.first
            
            if tdImage.count == 0 {
                self.widthForimageView.constant = 0
            } else {
                self.widthForimageView.constant = 99
            }
        }
    }
}
