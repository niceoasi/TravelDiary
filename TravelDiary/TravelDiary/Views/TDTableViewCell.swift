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
    var diary: Diary?
    var collasped = false
    
    // Initialization code
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
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
        
        tdDate.layer.borderColor = UIColor.blue.cgColor
        tdDate.layer.borderWidth = 1
        
        tdImageView?.layer.cornerRadius = (tdImageView?.frame.width)! / 2
        tdImageView?.layer.borderColor = UIColor.white.cgColor
        tdImageView?.layer.borderWidth = 1
        
        backgroundCardView.backgroundColor = .white
        backgroundCardView.layer.cornerRadius = 3
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8
        
        contentView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }
    
    func configureCell(diary: Diary) {
        self.diary = diary
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd일"
        
        let date = diary.date
        tdDate.text = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "EEEE"
        
        tdWeakday.text = dateFormatter.string(from: date)
        
        tdMemo.text = diary.text
        
        
        tdLocation.text = diary.locationName
        
        if let tdImage = diary.getPhotos() {
            tdImageView.image = tdImage.first
            
            if tdImage.count == 0 {
                widthForimageView.constant = 0
            } else {
                widthForimageView.constant = 99
            }
        }
    }
}
