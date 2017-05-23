//
//  TDDestination.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 17/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

// 필터 목록
enum RegionList: Int {
    case Asia = 0
    case Europe
    case NorthAmerica
    case SouthAmerica
    case Oceania
    case Africa
    
    func convertRegion() -> (region: String, color: UIColor) {
        switch self {
        case .Asia:
            return ("Asia", UIColor.FlatColor.Red.TerraCotta)
        case .Europe:
            return ("Europe", UIColor.FlatColor.Orange.Sun)
        case .NorthAmerica:
            return ("North America", UIColor.FlatColor.Yellow.Turbo)
        case .SouthAmerica:
            return ("South America", UIColor.FlatColor.Green.MountainMeadow)
        case .Oceania:
            return ("Oceania", UIColor.FlatColor.Blue.Mariner)
        case .Africa:
            return ("Africa", UIColor.FlatColor.Violet.Wisteria)
        }
    }
}

// Destination 모델
class Destination: Object {
    
    // MARK: - Properties
    dynamic var id = 0
    dynamic var destinationName: String = ""
    var diaries = List<Diary>()
    
     dynamic var departureDate: Date = Date()
     dynamic var arrivalDate: Date = Date()
    
    // Initialize
    convenience init(destinationName: String, departureDate: Date, arrivalDate: Date) {
        self.init()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddhhmmss"
        let currentID = dateFormatter.string(from: date)
        id = Int(currentID)!
        
        if destinationName == "" {
            self.destinationName = "목적지가 설정 되지 않았습니다."
        } else {
            self.destinationName = destinationName
        }
        
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
    }
    
    // MARK: - Functions
    // Get, Set Properties
    override static func primaryKey() -> String? {
        return "id"
    }
}
