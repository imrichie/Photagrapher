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
  
  lazy var resultsController: NSFetchedResultsController<Location> = {
    let fetchRequest = NSFetchRequest<Location>(entityName: Constants.Entities.location)
    let sort1 = NSSortDescriptor(key: "category", ascending: true)
    let sort2 = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sort1, sort2]
    
    fetchRequest.fetchBatchSize = 20
    
    let resultsController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: managedObjectContext,
      sectionNameKeyPath: Constants.DataManager.sectionNameKeyPath,
      cacheName: Constants.DataManager.cacheName)
    
    return resultsController
  }()
  
  deinit {
    resultsController.delegate = nil 
  }
  
  func fetchData() {
    do {
      try resultsController.performFetch()
    } catch {
      fatalError(">>> CORE DATA ERROR: \(error.localizedDescription)")
    }
  }
  
}
