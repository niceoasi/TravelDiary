//
//  TDTableViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 07/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class TDTableViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tdTableView: UITableView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    // MARK: - Properties
    let realm = try! Realm()
    var filteredDestination: Results<Destination>!
    var selectedRegion: (region: String, color: UIColor)?
    var collapse = false
    
    var sectionExpandedInfo : [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RealmController.shared = self.realm.objects(Destination.self)
        self.filteredDestination = RealmController.shared
        RealmController.filterd = self.filteredDestination
        
        self.collapseSection()
        
        let isCreatedImageFolder = UserDefaults.standard.value(forKey: "createImagesDirectory")
        if isCreatedImageFolder as! Bool {
            print("ImagesFolder already created.")
        } else {
            self.createImagesDirectory()
            print("Make ImagesFolder")
            UserDefaults.standard.set(true, forKey: "createImagesDirectory")
        }
        
        self.tdTableView.register(UINib(nibName: "TDTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TDTableHeaderView")
        
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.placeholderLabel.isHidden = true
        self.checkSectionCount()
        self.tdTableView.reloadData()
    }
}


// MARK: - Extensions
// Did Load Check Data
extension TDTableViewController {
    func createImagesDirectory() { // 처음 시작하면 폴더 만들기
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Images")
        
        try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        
        print("createDirectory : \(paths)")
    }
    
    func checkSectionCount() {
        var count = 0
        if let destinations = RealmController.shared {
            count = destinations.count
        }
        
        if count == 0 {
            self.placeholderLabel.isHidden = false
            
            let actionSheet = UIAlertController(title: "여행 기록이 없습니다.", message: "여행 기록을 추가 하시겠습니까?", preferredStyle: .actionSheet)
            
            let okayAction = UIAlertAction(title: "Okay", style: .default) { (alertAction) in
                self.newDestination(section: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(okayAction)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func collapseSection() {
        self.sectionExpandedInfo = []
        for index in 0..<self.filteredDestination.count {
            self.sectionExpandedInfo += [collapse]
        }
    }
}


// MARK: - Actions
extension TDTableViewController {
    
    @IBAction func collapseButtonTapped(_ sender: Any) {
        self.collapse = !self.collapse
        self.collapseSection()
        self.tdTableView.reloadData()
    }
    
    @IBAction func makeNewDiary(_ sender: Any) {
        self.newDestination(section: nil)
    }
    
    @IBAction func setFilter(_ sender: Any) {
        let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "TDFilterViewController") as! TDFilterViewController
        filterVC.delegate = self
        
        self.present(filterVC, animated: true, completion: nil)
    }
    
}

// MARK: - TDEditDestinationViewControllerDelegate, TDEditDiaryViewControllerDelegate
// 데이터(목적지 데이터, 목적지별 일기) 세이브 후 테이블 뷰 리로드
extension TDTableViewController: TDEditDestinationViewControllerDelegate {
    
    func didSaveDestination() {
        self.placeholderLabel.isHidden = true
        self.collapseSection()
        self.tdTableView.reloadData()
    }
}

// MARK: - TDTableHeaderViewCellDelegate
// 헤더에서 버튼 요청을 받아 작업
extension TDTableViewController: TDHeaderViewDelegate {

    func newDestination(section: Int?) {
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "TDEditDestinationViewController") as! TDEditDestinationViewController
        
        destinationVC.delegate = self
        destinationVC.section = section
        
        self.present(destinationVC, animated: false, completion: nil)
    }
    
    func collapseCell(section: Int) {
        
        self.sectionExpandedInfo[section] = !self.sectionExpandedInfo[section]
        
        self.tdTableView.reloadSections(IndexSet(integer:section), with: .fade)
    }
    
    func newDiaryFor(section: Int) {
        let editDiaryVC = self.storyboard!.instantiateViewController(withIdentifier: "TDEditDiaryViewController") as! TDEditDiaryViewController
        editDiaryVC.section = section
        
        self.present(editDiaryVC, animated: true, completion: nil)
    }
    
    func editDestinationFor(section: Int) {
        self.newDestination(section: section)
    }
    
    func deleteDestinationFor(section: Int) {
        let alertAction = UIAlertController(title: "기록을 삭제 하시겠습니까?", message: nil, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "예", style: .default) { (alertAction) in
            
            RealmController.deleteDestination(section: section)
            
            RealmController.shared = self.realm.objects(Destination.self)
            if let region = self.selectedRegion {
                self.setFilter(selectedRegion: region)
            } else {
                RealmController.filterd = RealmController.shared
            }
            
            self.collapseSection()
            self.tdTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertAction.addAction(okayAction)
        alertAction.addAction(cancelAction)
        
        self.present(alertAction, animated: true, completion: nil)
    }
    
    func showMapFor(section: Int) {
        let tdMapVC = self.storyboard?.instantiateViewController(withIdentifier: "TDMapViewController") as! TDMapViewController
        tdMapVC.section = section
        
        self.navigationController?.pushViewController(tdMapVC, animated: true)
    }
    
    func moreButtonTapped(alertVC: UIAlertController) {
        self.present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - TDFilterViewController Delegate
extension TDTableViewController: TDFilterViewControllerDelegate {
    func setFilter(selectedRegion: (region: String, color: UIColor)) {
        if selectedRegion.region == "All" {
            self.filteredDestination = RealmController.shared
            RealmController.filterd = self.filteredDestination
            
        } else {
            self.selectedRegion? = selectedRegion
            self.filteredDestination = RealmController.shared.filter("destinationName = %@", "\(selectedRegion.region)")
            RealmController.filterd = self.filteredDestination
            
        }
        self.collapseSection()
        self.tdTableView.reloadData()
    }
}

// MARK: - TableView
extension TDTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let destinations = self.filteredDestination {
            return destinations.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TDTableHeaderView") as! TDTableHeaderView
        
        let destination = self.filteredDestination[section]
        headerView.configureView(destination: destination, section: section, state: self.sectionExpandedInfo[section])
        
        headerView.delegate = self
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let row = self.filteredDestination[section].getDirayCount()
        
        if self.sectionExpandedInfo[section] {
            return 0
        } else {
            return row
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TDTableViewCell!
        
        let diary = self.filteredDestination[indexPath.section].getDiary(at: indexPath.row)
        
        cell = tableView.dequeueReusableCell(withIdentifier: "TDTableViewCell", for: indexPath) as! TDTableViewCell
        cell.configureCell(diary: diary!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        
        UIView.animate(withDuration: 1) {
            cell.alpha = 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tdDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "TDDetailViewController") as! TDDetailViewController
        
        tdDetailVC.indexPath = indexPath
        
        self.navigationController?.pushViewController(tdDetailVC, animated: true)
    }
}
