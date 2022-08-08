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
  }
  
  func configurePlacemark(_ placemark: CLPlacemark) -> String {
    var text = ""
    if let temp = placemark.subThoroughfare {
      text += temp + " "
    }
    
    if let temp = placemark.thoroughfare {
      text += temp + ", "
    }
    
    if let temp = placemark.locality {
      text += temp
    }
    return text
  }
  
  // MARK: - Table View
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locationManager.locations.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellNames.locationCell, for: indexPath)
    
    let descriptionLabel = cell.viewWithTag(100) as! UILabel
    let addressLabel = cell.viewWithTag(101) as! UILabel
    let location = locationManager.locations[indexPath.row]
    
    descriptionLabel.text = location.category
    if let placemark = location.placemark {
      addressLabel.text = configurePlacemark(placemark)
    } else {
      addressLabel.text = ""
    }
    
    return cell 
  }
}
