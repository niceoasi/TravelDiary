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
    let realm = try? Realm()
    var filteredDestination: Results<Destination>?
    var selectedRegion: (region: String, color: UIColor)?
    var collapse = false
    
    var sectionExpandedInfo : [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RealmController.shared = realm?.objects(Destination.self)
        filteredDestination = RealmController.shared
        RealmController.filterd = filteredDestination
        
        collapseSection()
        
        
        guard let isCreatedImageFolder = UserDefaults.standard.value(forKey: "createImagesDirectory") as? Bool else {
            print("ImagesFolder already created.")
            return
        }
        
        createImagesDirectory()
        print("Make ImagesFolder")
        UserDefaults.standard.set(true, forKey: "createImagesDirectory")
        
        
        tdTableView.register(UINib(nibName: "TDTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TDTableHeaderView")
        
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        placeholderLabel.isHidden = true
        checkSectionCount()
        tdTableView.reloadData()
    }
}


// MARK: - Extensions
// Did Load Check Data
extension TDTableViewController {
    func createImagesDirectory() { // 처음 시작하면 폴더 만들기
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Images")
        
        try? fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        
        print("createDirectory : \(paths)")
    }
    
    func checkSectionCount() {
        var count = 0
        if let destinations = RealmController.shared {
            count = destinations.count
        }
        
        if count == 0 {
            placeholderLabel.isHidden = false
            
            let actionSheet = UIAlertController(title: "여행 기록이 없습니다.", message: "여행 기록을 추가 하시겠습니까?", preferredStyle: .actionSheet)
            
            let okayAction = UIAlertAction(title: "Okay", style: .default) { (alertAction) in
                self.newDestination(section: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(okayAction)
            actionSheet.addAction(cancelAction)
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func collapseSection() {
        sectionExpandedInfo = []
        guard let count = filteredDestination?.count else {
            return
        }
        
        for _ in 0..<count {
            sectionExpandedInfo += [collapse]
        }
    }
}


// MARK: - Actions
extension TDTableViewController {
    
    @IBAction func collapseButtonTapped(_ sender: Any) {
        collapse = !collapse
        collapseSection()
        tdTableView.reloadData()
    }
    
    @IBAction func makeNewDiary(_ sender: Any) {
        newDestination(section: nil)
    }
    
    @IBAction func setFilter(_ sender: Any) {
        guard let filterVC = storyboard?.instantiateViewController(withIdentifier: "TDFilterViewController") as? TDFilterViewController else {
            return
        }
        filterVC.delegate = self
        
        present(filterVC, animated: true, completion: nil)
    }
    
}

// MARK: - TDEditDestinationViewControllerDelegate, TDEditDiaryViewControllerDelegate
// 데이터(목적지 데이터, 목적지별 일기) 세이브 후 테이블 뷰 리로드
extension TDTableViewController: TDEditDestinationViewControllerDelegate {
    
    func didSaveDestination() {
        placeholderLabel.isHidden = true
        collapseSection()
        tdTableView.reloadData()
    }
}

// MARK: - TDTableHeaderViewCellDelegate
// 헤더에서 버튼 요청을 받아 작업
extension TDTableViewController: TDHeaderViewDelegate {

    func newDestination(section: Int?) {
        guard let destinationVC = storyboard?.instantiateViewController(withIdentifier: "TDEditDestinationViewController") as? TDEditDestinationViewController else {
            return
        }
        
        destinationVC.delegate = self
        destinationVC.section = section
        
        present(destinationVC, animated: false, completion: nil)
    }
    
    func collapseCell(section: Int) {
        
        sectionExpandedInfo[section] = !sectionExpandedInfo[section]
        
        tdTableView.reloadSections(IndexSet(integer:section), with: .fade)
    }
    
    func newDiaryFor(section: Int) {
        guard let editDiaryVC = storyboard?.instantiateViewController(withIdentifier: "TDEditDiaryViewController") as? TDEditDiaryViewController else {
            return
        }
        editDiaryVC.section = section
        
        present(editDiaryVC, animated: true, completion: nil)
    }
    
    func editDestinationFor(section: Int) {
        newDestination(section: section)
    }
    
    func deleteDestinationFor(section: Int) {
        let alertAction = UIAlertController(title: "기록을 삭제 하시겠습니까?", message: nil, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "예", style: .default) { (alertAction) in
            
            RealmController.deleteDestination(section: section)
            
            RealmController.shared = self.realm?.objects(Destination.self)
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
        
        present(alertAction, animated: true, completion: nil)
    }
    
    func showMapFor(section: Int) {
        guard let tdMapVC = storyboard?.instantiateViewController(withIdentifier: "TDMapViewController") as? TDMapViewController else {
            return
        }
        tdMapVC.section = section
        
        navigationController?.pushViewController(tdMapVC, animated: true)
    }
    
    func moreButtonTapped(alertVC: UIAlertController) {
        present(alertVC, animated: true, completion: nil)
    }
}

// MARK: - TDFilterViewController Delegate
extension TDTableViewController: TDFilterViewControllerDelegate {
    func setFilter(selectedRegion: (region: String, color: UIColor)) {
        if selectedRegion.region == "All" {
            filteredDestination = RealmController.shared
            RealmController.filterd = filteredDestination
            
        } else {
            self.selectedRegion = selectedRegion
            filteredDestination = RealmController.shared?.filter("destinationName = %@", "\(selectedRegion.region)")
            RealmController.filterd = filteredDestination
            
        }
        collapseSection()
        tdTableView.reloadData()
    }
}

// MARK: - TableView
extension TDTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let destinations = filteredDestination {
            return destinations.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TDTableHeaderView") as? TDTableHeaderView
        
        if let destination = filteredDestination?[section] {
        
            headerView?.configureView(destination: destination, section: section, state: sectionExpandedInfo[section])
            headerView?.delegate = self
            
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let row = filteredDestination?[section].diaries.count {

            if sectionExpandedInfo[section] {
                return 0
            } else {
                return row
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dummyCell = TDTableViewCell()
        
        guard let diary = filteredDestination?[indexPath.section].diaries[indexPath.row] else  {
            return dummyCell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TDTableViewCell", for: indexPath) as? TDTableViewCell else {
            return dummyCell
        }
        
        cell.configureCell(diary: diary)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        
        UIView.animate(withDuration: 1) {
            cell.alpha = 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let tdDetailVC = storyboard?.instantiateViewController(withIdentifier: "TDDetailViewController") as? TDDetailViewController else {
            return
        }
        
        tdDetailVC.indexPath = indexPath
        
        navigationController?.pushViewController(tdDetailVC, animated: true)
    }
}
