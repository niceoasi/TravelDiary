//
//  TDFilterViewController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 24/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
protocol TDFilterViewControllerDelegate: class {
    func setFilter(selectedRegion: (region: String, color: UIColor))
}

class TDFilterViewController: UITableViewController {
    
    var selectedRegion: (String, UIColor)?
    weak var delegate: TDFilterViewControllerDelegate?
    
    var saveButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        saveButton.isEnabled = false
        saveButton.setTitleColor(UIColor.FlatColor.Gray.WhiteSmoke, for: .disabled)
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 7
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.section == 0 {
            let cgSize = CGSize(width: view.frame.width / 2, height: cell.frame.height)
            let color = UIColor.FlatColor.Blue.CuriousBlue
            let cancelButton = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: 0) , size: cgSize))
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(color, for: .normal)
            cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            saveButton = UIButton(frame: CGRect(origin: CGPoint(x: view.frame.width / 2, y: 0), size: cgSize))
            saveButton.setTitle("Save", for: .normal)
            saveButton.setTitleColor(color, for: .normal)
            saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
            cell.addSubview(cancelButton)
            cell.addSubview(saveButton)
            
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "All"
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = UIColor.FlatColor.Violet.BlueGem
            } else {
                let region = RegionList(rawValue: indexPath.row - 1)?.convertRegion().region
                let color = RegionList(rawValue: indexPath.row - 1)?.convertRegion().color
                cell.textLabel?.text = region
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = color
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                selectedRegion = ("All", UIColor.FlatColor.Violet.BlueGem)
            } else {
                let region = RegionList(rawValue: indexPath.row - 1)?.convertRegion()
            
                selectedRegion = region
            }
            
            saveButton.isEnabled = true
        }
    }
}

// MARK: - Actions
extension TDFilterViewController {

    @IBAction func save() {
        guard let selected = selectedRegion else {
            return
        }
        delegate?.setFilter(selectedRegion: selected)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
