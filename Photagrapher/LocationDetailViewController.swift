//
//  LocationDetailViewController.swift
//  Photagrapher
//
//  Created by Richie Flores on 7/28/22.
//  Property of AppLimited L.L.C.
//

import UIKit
import CoreLocation

// MARK: - Lazy Objects
private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  return formatter
}()

class LocationDetailViewController: UITableViewController {
  
  @IBOutlet var descriptionTextView: UITextView!
  @IBOutlet var categoryLabel: UILabel!
  @IBOutlet var latitudeLabel: UILabel!
  @IBOutlet var longitutudeLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  
  var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    descriptionTextView.text = ""
    categoryLabel.text = ""
    
    latitudeLabel.text = String(format: "%.8f", coordinates.latitude)
    longitutudeLabel.text = String(format: "%.8f", coordinates.longitude)
    
    if let placemark = placemark {
      addressLabel.text = formatAddress(from: placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    dateLabel.text = format(date: Date())
  }
  
  // MARK: - Private Methods
  func formatAddress(from: CLPlacemark) -> String {
    var text = ""
    if let temp = placemark?.subThoroughfare {
      text += temp + " "
    }
    
    if let temp = placemark?.thoroughfare {
      text += temp + ", "
    }
    
    if let temp = placemark?.locality {
      text += temp + ", "
    }
    
    if let temp = placemark?.administrativeArea {
      text += temp + " "
    }
    
    if let temp = placemark?.postalCode {
      text += temp + ", "
    }
    
    if let temp = placemark?.country {
      text += temp
    }
    return text
  }
  
  func format(date: Date) -> String {
    return dateFormatter.string(from: date)
  }
  
  
  // MARK: - Actions
  @IBAction func done() {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cancel() {
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
