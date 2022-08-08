//
//  LocationManager.swift
//  Photagrapher
//
//  Created by Richie Flores on 8/7/22.
//

import Foundation
import CoreData

class LocationManager {
  var managedObjectContext: NSManagedObjectContext!
  var locations = [Location]()
  
  func fetchData() {
    let fetchRequest = NSFetchRequest<Location>(entityName: Constants.Entities.location)
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    do {
      locations = try managedObjectContext.fetch(fetchRequest)
    } catch {
      fatalError(">>> ERROR: \(error.localizedDescription)")
    }
  }
}
