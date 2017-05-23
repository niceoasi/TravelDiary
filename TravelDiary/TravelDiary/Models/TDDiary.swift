//
//  TDDiary.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 07/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RealmSwift
import Realm

// Diary 모델
class Diary: Object {
    
    // MARK: - Properties
    dynamic var id = 0
    dynamic var title: String = ""
    dynamic var date: Date = Date()
    dynamic var text: String = ""
    dynamic var locationName: String = ""
    var latitude = RealmOptional<Double>()
    var longitude = RealmOptional<Double>()
    var dirPathForPhotos = List<DirPathForImage>()
    
    // Initialize
    convenience init(title: String = "", date: Date = Date(), latitude: Double? = nil, longitude: Double? = nil, text: String = "", locatonName: String = "", images: [UIImage]) {
        self.init()
        
        let dateForID = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddhhmmss"
        let currentID = dateFormatter.string(from: dateForID)
        id = Int(currentID)!
        
        self.title = title
        self.date = date
        self.text = text
        locationName = locatonName
        
        if let tdlatitude = latitude {
            self.latitude.value = tdlatitude
        }
        if let tdlongitude = longitude {
            self.longitude.value = tdlongitude
        }
        
        if !images.isEmpty {
            addPhotos(images: images)
        }
        
    }
    
    // MARK: - Functions
    // Get, Set Properties
    override static func primaryKey() -> String? {
        return "id"
    }
    
    public func getLocation() -> (latitude: Double?, longitude: Double?) {
        return (latitude.value, longitude.value)
    }
    
    
    public func getPhotos() -> [UIImage]? {
        var photos = [UIImage]()
        
        for index in 0..<dirPathForPhotos.count {
            if let photo = ImageController.getPhoto(at: index, dirPathForPhotos: dirPathForPhotos) {
                photos += [photo]
            } else {
                print("Erro No Image File")
                return nil
            }
        }
        
        return photos
    }
    
    public func addPhotos(images: [UIImage]) {
        dirPathForPhotos = ImageController.saveImagesDocumentDirectory(images: images, dirPathForPhotos: dirPathForPhotos)
    }
}

// MARK: - ImageController
// 사진 저장과 가져오는 Controller
class ImageController {
    
    class func getPhoto(at index: Int, dirPathForPhotos: List<DirPathForImage>) -> UIImage? {
        let fileManager = FileManager.default
        let path = dirPathForPhotos[index].dirPath
        let imagePAth = (ImageController.getDirectoryPath() as NSString).appendingPathComponent(path)
            
        if fileManager.fileExists(atPath: imagePAth){
            let image = UIImage(contentsOfFile: imagePAth)
            return image
        } else {
            print("Erro No Image File")
            return nil
        }
    }
    
    class func saveImagesDocumentDirectory(images: [UIImage], dirPathForPhotos: List<DirPathForImage>) -> List<DirPathForImage> {
        var index = 0
        for image in images {
            let dirPathForImage = DirPathForImage(index: index)
            
            let fileManager = FileManager.default
            let path = "Images/\(dirPathForImage.id).jpg"
            
            dirPathForImage.dirPath = path
            dirPathForPhotos.append(dirPathForImage)
            let paths = (getDirectoryPath() as NSString).appendingPathComponent(path)
            let image = image
            let imageData = UIImageJPEGRepresentation(image, 0.1)
            fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
            
            index += 1
        }
        return dirPathForPhotos
    }
    
    class func deletePhoto(dirPathForPhotos: List<DirPathForImage>) {
        let fileManager = FileManager.default
        for dirPathForPhoto in dirPathForPhotos {
            let paths = (ImageController.getDirectoryPath() as NSString).appendingPathComponent(dirPathForPhoto.dirPath)
            if fileManager.fileExists(atPath: paths){
                try! fileManager.removeItem(atPath: paths)
            }else{
                print("Something wrong.")
            }
        }
    }
    
    class func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
}

// MARK: - DirPathForImage
// 이미지의 위치 정보가 저장되는 모델
class DirPathForImage: Object {
    dynamic var id = 0
    dynamic var dirPath: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(index: Int) {
        self.init()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddhhmmss"
        
        let currentID = dateFormatter.string(from: date) + "\(index)"
        
        if let id = Int(currentID) {
            self.id = id
        }
    }
}
