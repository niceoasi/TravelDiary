//
//  TDDetailViewCell.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 19/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

protocol TDDetailViewCellDelegate: class {
    func showPhotos(photos: [UIImage]?)
}

class TDDetailViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tdTitle: UILabel!
    @IBOutlet weak var tdDate: UILabel!
    @IBOutlet weak var tdLocation: UILabel!
    @IBOutlet weak var tdMemo: UITextView!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    // Set for UI
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet var uiCardViewViewCollection: [UIView]!
    @IBOutlet weak var photoCardView: UIView!
    // Set for UI
    @IBOutlet weak var heightForCollectionView: NSLayoutConstraint!
    
    
    var photos: [UIImage]?
    
    weak var delegate: TDDetailViewCellDelegate?
    
    func setCell(diary: Diary) {
        
        setCellUI()
        photosCollectionView.register(UINib(nibName: "TDImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TDImageCollectionViewCell")
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        tdDate.text = dateFormatter.string(from: diary.date)
        
        tdTitle.text = diary.title
        tdLocation.text = diary.locationName
        if tdLocation.text != "" {
            tdLocation.text = "/ " + tdLocation.text!
        }
            
        tdMemo.text = diary.text
        photos = diary.getPhotos()
        
        if photos?.count == 0 {
            heightForCollectionView.constant = 0
        } else {
            heightForCollectionView.constant = 120
        }
        
        photosCollectionView.reloadData()
    }
}

extension TDDetailViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        
        if let photos = photos {
            count = photos.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDImageCollectionViewCell", for: indexPath) as! TDImageCollectionViewCell
        
        let photo = (photos?[indexPath.row])!
        cell.configureCell(tdImage: photo, isClipTrue: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let photos = photos {
            delegate?.showPhotos(photos: photos)
        }
    }
    
    func setCellUI() {
        
        for uiCardView in uiCardViewViewCollection {
            uiCardView.backgroundColor = .white
            uiCardView.layer.cornerRadius = 3
            uiCardView.layer.masksToBounds = false
            uiCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            uiCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
            uiCardView.layer.shadowOpacity = 0.8
        }
        
        photoCardView.backgroundColor = .black
        
        cellContentView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }
}
