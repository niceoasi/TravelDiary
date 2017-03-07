//
//  TDImageViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 09/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

class TDImageViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tdCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Properties
    var tdImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tdCollectionView.register(UINib(nibName: "TDImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TDImageCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.setupFlowLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
}

// MARK: - Extensions
// MARK: - FlowLayout
extension TDImageViewController {
    func setupFlowLayout() {
        self.flowLayout.minimumInteritemSpacing = 0
        self.flowLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    }
}

// MARK: - CollectionView
extension TDImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tdImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDImageCollectionViewCell", for: indexPath) as! TDImageCollectionViewCell
        
        let tdImage = self.tdImages[indexPath.row]
        cell.configureCell(tdImage: tdImage, isClipTrue: false)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
