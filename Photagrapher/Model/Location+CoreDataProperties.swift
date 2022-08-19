//
//  Location+CoreDataProperties.swift
//  Photagrapher
//
//  Created by Richie Flores on 8/1/22.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
    return NSFetchRequest<Location>(entityName: "Location")
  }
  
  @NSManaged public var longitude: Double
  @NSManaged public var latitude: Double
  @NSManaged public var date: Date
  @NSManaged public var locationDescription: String
  @NSManaged public var category: String
  @NSManaged public var placemark: CLPlacemark?
  @NSManaged public var isFavorite: Bool
}

extension Location : Identifiable {
  
}
