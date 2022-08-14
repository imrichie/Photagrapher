//
//  LocationsViewController.swift
//  Photagrapher
//
//  Created by Richie Flores on 8/2/22.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
  var locationManager: LocationManager!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.resultsController.delegate = self 
    locationManager.fetchData()
    registerTableViewCells()
    navigationItem.rightBarButtonItem = editButtonItem
  }
  
  func registerTableViewCells() {
    let locationCell  = UINib(nibName: Constants.CellNames.locationCellNibName, bundle: nil)
    tableView.register(locationCell, forCellReuseIdentifier: Constants.CellNames.locationCell)
  }
  
  // MARK: - Table View
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = locationManager.resultsController.sections else { return 0 }
    return sections[section].numberOfObjects
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    guard let sections = locationManager.resultsController.sections else { return 0}
    return sections.count
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let sectionInfo = locationManager.resultsController.sections else { return ""}
    return sectionInfo[section].name
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let locationCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellNames.locationCell, for: indexPath) as! LocationCell
    let location = locationManager.resultsController.object(at: indexPath)
    locationCell.configure(for: location)
    
    return locationCell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: Constants.SegueNames.editLocation, sender: self)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let location = locationManager.resultsController.object(at: indexPath)
      locationManager.managedObjectContext.delete(location)
      do {
        try locationManager.managedObjectContext.save()
      } catch {
        fatalError(">>> CORE DATA ERROR - Saving: \(error.localizedDescription)")
      }
    }
  }
  
  // Swipe Actions
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    // Delete Action
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
      print(">>> Deleting location...")
      let location = self.locationManager.resultsController.object(at: indexPath)
      self.locationManager.managedObjectContext.delete(location)
      do {
        try self.locationManager.managedObjectContext.save()
      } catch {
        fatalError(">>> CORE DATA ERROR - Deleting: \(error.localizedDescription)")
      }
    }
    deleteAction.image = UIImage(systemName: "trash")
    
    // Favorite Action
    let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { action, view, handler in
      print(">>> Favorite Button Clicked")
      let selectedLocation = self.locationManager.resultsController.object(at: indexPath)
      selectedLocation.isFavorite.toggle()
      
      do {
        try self.locationManager.managedObjectContext.save()
      } catch {
        fatalError(">>> CORE DATA - Favorites: \(error.localizedDescription)")
      }
    }
    favoriteAction.image = UIImage(systemName: "star")
    favoriteAction.backgroundColor = .systemBlue
    
    let configuration = UISwipeActionsConfiguration(actions: [deleteAction, favoriteAction])
    return configuration
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.SegueNames.editLocation {
      let controller = segue.destination as! LocationDetailViewController
      if let selectedRow = tableView.indexPathForSelectedRow {
        controller.locationToEdit = locationManager.resultsController.object(at: selectedRow)
        controller.locationManager = locationManager
      }
    }
  }
}

extension LocationsViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print(">>> ControllerWillChangeContent")
    tableView.beginUpdates()
  }
  
  func controller(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>,
    didChange anObject: Any,
    at indexPath: IndexPath?,
    for type: NSFetchedResultsChangeType,
    newIndexPath: IndexPath?) {
      switch type {
        case .insert:
          print(">>> NSFetchedResultsChangedInsert (object)")
          tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
          print(">>> NSFetchedResultsChangeDelete (object)")
          tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
          print(">>> NSFetchedResultsChangeUpdate (object")
          if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
            let location = controller.object(at: indexPath!) as! Location
            cell.configure(for: location)
          }
        case .move:
          print(">>> NSFetchedResultsChangeMove (object)")
          tableView.deleteRows(at: [indexPath!], with: .fade)
          tableView.insertRows(at: [newIndexPath!], with: .fade)
          
        @unknown default:
          print(">>> NSFetchedResults unknown type")
      }
    }
  
  func controller(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>,
    didChange sectionInfo: NSFetchedResultsSectionInfo,
    atSectionIndex sectionIndex: Int,
    for type: NSFetchedResultsChangeType) {
      switch type {
        case .insert:
          print(">>> NSFetchedResultsChangedInsert (section)")
          tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
          print(">>> NSFetchedResultsChangeDelete (section")
          tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
          print(">>> NSFetchedResultsChangeUpdate (section")
        case .move:
          print(">>> NSFetchedResultsChangeMove (section")
        @unknown default:
          print(">>> NSFetchedResults unknown type")
      }
    }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    print(">>> controllerDidChangeContent")
    tableView.endUpdates()
  }
}
