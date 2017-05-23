//
//  TDMapTableViewCell.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 20/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

protocol TDMapTableViewCellDelegate: class {
    func mapTableTapped(diary: Diary)
}

class TDMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapTableCellTitleLabel: UILabel!
    @IBOutlet weak var mapTableCellDateLabel: UILabel!
    @IBOutlet weak var mapTableLocationLabel: UILabel!
    
    @IBOutlet weak var backgroundCardView: UIView!
    
    var diary: Diary?
    weak var delegate: TDMapTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundCardView.backgroundColor = .white
        backgroundCardView.layer.cornerRadius = 3
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8
        
        contentView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(diary: Diary) {
        self.diary = diary
        
        mapTableCellTitleLabel.text = diary.title
        
        let date = diary.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 MM월 dd일"
        mapTableCellDateLabel.text = dateFormatter.string(from: date)
        
        mapTableLocationLabel.text = diary.locationName
    }
    
    @IBAction func cellTapped(_ sender: Any) {
        guard let diary = self.diary else {
            return
        }
        delegate?.mapTableTapped(diary: diary)
    }
    
}
