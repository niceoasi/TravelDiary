//
//  TDDetailViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 07/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import RealmSwift

class TDDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tdCollectionView: UICollectionView!
    
    // MARK: - Properties
    var tdImages = [UIImage]()
    var indexPath = IndexPath()
    var diaries = List<Diary>()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        tdCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentSize = tdCollectionView.bounds.size
        
        var offset: CGFloat = 0
        let row = indexPath.row
        
        offset = CGFloat(row) * currentSize.height
        
        let point = CGPoint(x: 0, y: offset)
        tdCollectionView.setContentOffset(point, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
}


// MARK: - Extensions
// MARK: - Actions
extension TDDetailViewController {
    
    @IBAction func modifyTD(_ sender: AnyObject) {
        guard let editDiaryVC = storyboard?.instantiateViewController(withIdentifier: "TDEditDiaryViewController") as? TDEditDiaryViewController else {
            return
        }
        
        if let centerCellIndexPath: NSIndexPath  = tdCollectionView.centerCellIndexPath {
            editDiaryVC.section = indexPath.section
            editDiaryVC.row = centerCellIndexPath.row
        }
        
        present(editDiaryVC, animated: false, completion: nil)
    }
    
    @IBAction func deleteTD(_ sender: AnyObject) {
        if let centerCellIndexPath: NSIndexPath  = tdCollectionView.centerCellIndexPath {
            
            let alertAction = UIAlertController(title: "기록을 삭제 하시겠습니까?", message: nil, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "예", style: .default) { (alertAction) in
                
                if let destination = RealmController.shared?[self.indexPath.section] {
                    let diary = destination.diaries[centerCellIndexPath.row]
                    RealmController.deleteDiary(destination: destination, row: centerCellIndexPath.row, diary: diary)
                    
                    if let diaryIsEmpty = RealmController.shared?[centerCellIndexPath.section].diaries.isEmpty {
                        if diaryIsEmpty {
                            self.navigationController?.popViewController(animated: true)
                        }
                        else {
                            self.tdCollectionView.reloadData()
                        }
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alertAction.addAction(okayAction)
            alertAction.addAction(cancelAction)
            
            present(alertAction, animated: true, completion: nil)
        }
    }
}

// MARK: - TDDetailViewCellDelegate
extension TDDetailViewController: TDDetailViewCellDelegate {
    func showPhotos(photos: [UIImage]?) {
        
        guard let imageVC = storyboard?.instantiateViewController(withIdentifier: "TDImageViewController") as? TDImageViewController else {
            return
        }
        
        guard let images = photos else {
            return
        }
        
        imageVC.tdImages = images
        
        navigationController?.pushViewController(imageVC, animated: true)
    }
}

// MARK: - CollectionView
extension TDDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = indexPath.section
        
        var count = 0
        if let diaries = RealmController.filterd?[section].diaries {
            count = diaries.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dummyCell = TDDetailViewCell()
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDDetailViewCell", for: indexPath) as? TDDetailViewCell else {
            return dummyCell
        }
        cell.delegate = self
        
        let diary = diaries[indexPath.row]
        
        cell.setCell(diary: diary)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 48 - 8 - 60 - 8)
    }
}

