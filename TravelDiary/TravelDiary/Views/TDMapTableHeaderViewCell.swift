//
//  TDMapTableHeaderViewCell.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 20/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

class TDMapTableHeaderViewCell: UITableViewCell {

    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    
    // Initialization code
    override func awakeFromNib() {
        super.awakeFromNib()
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

}
