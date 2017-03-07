//
//  TDDetailViewCell.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 19/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

protocol TDDetailViewCellDelegate {
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
    
    var delegate: TDDetailViewCellDelegate?
    
    func setCell(diary: Diary) {
        
        self.setCellUI()
        self.photosCollectionView.register(UINib(nibName: "TDImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TDImageCollectionViewCell")
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        self.tdDate.text = dateFormatter.string(from: diary.getDate())
        
        self.tdTitle.text = diary.getTitle()
        self.tdLocation.text = diary.getLocationName()
        if self.tdLocation.text != "" {
            self.tdLocation.text = "/ " + self.tdLocation.text!
        }
            
        self.tdMemo.text = diary.getText()
        self.photos = diary.getPhotos()
        
        if self.photos?.count == 0 {
            self.heightForCollectionView.constant = 0
        } else {
            self.heightForCollectionView.constant = 120
        }
        
        self.photosCollectionView.reloadData()
    }
}

extension TDDetailViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        
        if let photos = self.photos {
            count = photos.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDImageCollectionViewCell", for: indexPath) as! TDImageCollectionViewCell
        
        let photo = (self.photos?[indexPath.row])!
        cell.configureCell(tdImage: photo, isClipTrue: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let photos = self.photos {
            self.delegate?.showPhotos(photos: photos)
        }
    }
    
    func setCellUI() {
        
        for uiCardView in self.uiCardViewViewCollection {
            uiCardView.backgroundColor = .white
            uiCardView.layer.cornerRadius = 3
            uiCardView.layer.masksToBounds = false
            uiCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            uiCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
            uiCardView.layer.shadowOpacity = 0.8
        }
        
        self.photoCardView.backgroundColor = .black
        
        self.cellContentView.backgroundColor = UIColor(red: 240/255.5, green: 240/255.5, blue: 240/255.5, alpha: 1)
    }
}
