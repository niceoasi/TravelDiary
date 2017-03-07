//
//  TDImageCollectionViewCell.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 10/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit


class TDImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tdImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tdImageView.layer.cornerRadius = (tdImageView?.frame.width)! / 2
        // Initialization code
        
    }
    
    func configureCell(tdImage: UIImage, isClipTrue: Bool) {
        
        self.tdImageView.image = tdImage
        
        if !isClipTrue {
            self.tdImageView.clipsToBounds = false
        }
    }
}
