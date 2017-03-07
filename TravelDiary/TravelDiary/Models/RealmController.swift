//
//  RealmController.swift
//  TravelDiary
//
//  Created by Daeyun Ethan Kim on 27/02/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import Foundation
import RealmSwift

class RealmController {
    static var shared: Results<Destination>!
    static var filterd: Results<Destination>!
    
    class func deleteDestination(section: Int) {
        
        let destination = self.filterd[section]
        let diaries = destination.getDiaries()
        
        let realm = try! Realm()
        
        try! realm.write {
            for diary in diaries {
                ImageController.deletePhoto(dirPathForPhotos: diary.dirPathForPhotos)
                realm.delete(diary.dirPathForPhotos)
            }
            
            realm.delete(diaries)
            realm.delete(destination)
        }
    }
    
    class func addDestination(section: Int?, destinationText: String, departureDate: Date, arrivalDate: Date) {
        
        let realm = try! Realm()
        if let section = section {
            let destination = RealmController.shared[section]
            try! realm.write {
                destination.destinationName = destinationText
                destination.departureDate = departureDate
                destination.arrivalDate = arrivalDate
            }
        } else {
            let destination = Destination(destinationName: destinationText, departureDate: departureDate, arrivalDate: arrivalDate)
            try! realm.write {
                realm.add(destination)
            }
        }
    }
    
    class func changeDiary(row: Int, destination: Destination, diary: Diary, willAddPhotos: [UIImage], willDeletePhotosPath: [String]) {
        let realm = try! Realm()
        
        try! realm.write {
            destination.diaries[row].title = diary.title
            destination.diaries[row].date = diary.date
            destination.diaries[row].text = diary.text
            destination.diaries[row].locationName = diary.locationName
            if let isLatitude = diary.latitude.value {
                destination.diaries[row].latitude.value = isLatitude
            }
            if let islongitude = diary.longitude.value {
                destination.diaries[row].longitude.value = islongitude
            }
            if willAddPhotos.count != 0 {
                destination.diaries[row].addPhotos(images: willAddPhotos)
            }
            
            let willDeletePhotos = List<DirPathForImage>()
            
            for willDeletePhoto in willDeletePhotosPath {
                let path = DirPathForImage()
                path.setDirPath(dirPath: willDeletePhoto)
                willDeletePhotos.append(path)
                
                var index = 0
                for photo in destination.diaries[row].dirPathForPhotos {
                    if photo.dirPath == willDeletePhoto {
                        let deletePhoto = destination.diaries[row].dirPathForPhotos[index]
                        destination.diaries[row].dirPathForPhotos.remove(at: index)
                        realm.delete(deletePhoto)
                    }
                    index += 1
                }
            }
            
            ImageController.deletePhoto(dirPathForPhotos: willDeletePhotos)
            
        }
    }
    
    class func addDiary(destination: Destination, diary: Diary) {

        let realm = try! Realm()
        try! realm.write {
            destination.addDiary(diary: diary)
        }
    }
    
    class func deleteDiary(destination: Destination, row: Int, diary: Diary) {
        let realm = try! Realm()
        
        try! realm.write {
            destination.deleteDiary(at: row)
            let photos = diary.dirPathForPhotos
            if photos.count != 0 {
                ImageController.deletePhoto(dirPathForPhotos: photos)
                realm.delete(photos)
            }
            realm.delete(diary)
        }
    }
}
