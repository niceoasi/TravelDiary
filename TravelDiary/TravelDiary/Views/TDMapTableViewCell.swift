//
//  TDMapTableViewCell.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 20/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

protocol TDMapTableViewCellDelegate {
    func mapTableTapped(diary: Diary)
}

class TDMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapTableCellTitleLabel: UILabel!
    @IBOutlet weak var mapTableCellDateLabel: UILabel!
    @IBOutlet weak var mapTableLocationLabel: UILabel!
    
    @IBOutlet weak var backgroundCardView: UIView!
    
    var diary: Diary!
    var delegate: TDMapTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundCardView.backgroundColor = .white
        self.backgroundCardView.layer.cornerRadius = 3
        self.backgroundCardView.layer.masksToBounds = false
        self.backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backgroundCardView.layer.shadowOpacity = 0.8
        
        self.contentView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(diary: Diary) {
        self.diary = diary
        
        self.mapTableCellTitleLabel.text = self.diary.getTitle()
        
        let date = self.diary.getDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 MM월 dd일"
        self.mapTableCellDateLabel.text = dateFormatter.string(from: date)
        
        self.mapTableLocationLabel.text = self.diary.getLocationName()
    }
    
    @IBAction func cellTapped(_ sender: Any) {
        self.delegate?.mapTableTapped(diary: self.diary)
    }
    
}
