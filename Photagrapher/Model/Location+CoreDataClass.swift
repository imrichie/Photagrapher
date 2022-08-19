//
//  Location+CoreDataClass.swift
//  Photagrapher
//
//  Created by Richie Flores on 8/1/22.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  public var title: String? {
    return locationDescription.isEmpty ? "(No Description)" : locationDescription
  }
  
  public var subtitle: String? {
    return category
  }
}
