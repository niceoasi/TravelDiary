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
        
        tdCollectionView.register(UINib(nibName: "TDImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TDImageCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        setupFlowLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
}

// MARK: - Extensions
// MARK: - FlowLayout
extension TDImageViewController {
    func setupFlowLayout() {
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
    }
}

// MARK: - CollectionView
extension TDImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tdImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dummyCell = TDImageCollectionViewCell()
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDImageCollectionViewCell", for: indexPath) as? TDImageCollectionViewCell else {
            return dummyCell
        }
        
        let tdImage = tdImages[indexPath.row]
        cell.configureCell(tdImage: tdImage, isClipTrue: false)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
