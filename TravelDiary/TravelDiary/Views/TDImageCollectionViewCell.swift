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
        guard let view = tdImageView else {
            return
        }
        
        tdImageView.layer.cornerRadius = view.frame.width / 2
        // Initialization code
        
    }
    
    func configureCell(tdImage: UIImage, isClipTrue: Bool) {
        
        tdImageView.image = tdImage
        
        if !isClipTrue {
            tdImageView.clipsToBounds = false
        }
    }
}

