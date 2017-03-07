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
    var indexPath: IndexPath!
    var diaries = List<Diary>()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.tdCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentSize = self.tdCollectionView.bounds.size
        let offset = CGFloat(self.indexPath.row) * currentSize.height
        let point = CGPoint(x: 0, y: offset)
        self.tdCollectionView.setContentOffset(point, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
}


// MARK: - Extensions
// MARK: - Actions
extension TDDetailViewController {
    
    @IBAction func modifyTD(_ sender: AnyObject) {
        let editDiaryVC = self.storyboard?.instantiateViewController(withIdentifier: "TDEditDiaryViewController") as! TDEditDiaryViewController
        
        if let centerCellIndexPath: NSIndexPath  = self.tdCollectionView.centerCellIndexPath {
            editDiaryVC.section = self.indexPath.section
            editDiaryVC.row = centerCellIndexPath.row
        }
        
        self.present(editDiaryVC, animated: false, completion: nil)
    }
    
    @IBAction func deleteTD(_ sender: AnyObject) {
        if let centerCellIndexPath: NSIndexPath  = self.tdCollectionView.centerCellIndexPath {
            
            let alertAction = UIAlertController(title: "기록을 삭제 하시겠습니까?", message: nil, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "예", style: .default) { (alertAction) in
                
                let destination = RealmController.shared[self.indexPath.section]
                let diary = destination.getDiary(at: centerCellIndexPath.row)
                
                RealmController.deleteDiary(destination: destination, row: centerCellIndexPath.row, diary: diary!)
                
                if RealmController.shared[centerCellIndexPath.section].getDirayCount() == 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.tdCollectionView.reloadData()
                }
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alertAction.addAction(okayAction)
            alertAction.addAction(cancelAction)
            
            self.present(alertAction, animated: true, completion: nil)
        }
    }
}

// MARK: - TDDetailViewCellDelegate
extension TDDetailViewController: TDDetailViewCellDelegate {
    func showPhotos(photos: [UIImage]?) {
        
        let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "TDImageViewController") as! TDImageViewController
        
        imageVC.tdImages = photos!
        
        self.navigationController?.pushViewController(imageVC, animated: true)
    }
}

// MARK: - CollectionView
extension TDDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = self.indexPath.section
        
        self.diaries = RealmController.filterd[section].getDiaries()
        
        var count = 0
        
        count = self.diaries.count
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDDetailViewCell", for: indexPath) as! TDDetailViewCell
        cell.delegate = self
        
        let diary = self.diaries[indexPath.row]
        
        cell.setCell(diary: diary)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height - 48 - 8 - 60 - 8)
    }
}

