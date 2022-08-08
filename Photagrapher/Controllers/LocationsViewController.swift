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
    locationManager.fetchData()
    registerTableViewCells()
  }  
  
  func registerTableViewCells() {
    let locationCell  = UINib(nibName: Constants.CellNames.locationCellNibName, bundle: nil)
    tableView.register(locationCell, forCellReuseIdentifier: Constants.CellNames.locationCell)
  }
  
  // MARK: - Table View
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locationManager.locations.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let locationCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellNames.locationCell, for: indexPath) as! LocationCell
    let location = locationManager.locations[indexPath.row]
    locationCell.configure(for: location)
    
    return locationCell
  }
}
