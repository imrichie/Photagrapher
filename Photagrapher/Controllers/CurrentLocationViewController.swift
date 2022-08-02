//
//  ViewController.swift
//  Photagrapher
//
//  Created by AppLimited Software LLC on 7/8/22.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController {
  
  @IBOutlet weak var messageLabel:    UILabel!
  @IBOutlet weak var latitudeLabel:   UILabel!
  @IBOutlet weak var longitudeLabel:  UILabel!
  @IBOutlet weak var addressLabel:    UILabel!
  @IBOutlet weak var tagButton:       UIButton!
  @IBOutlet weak var getButton:       UIButton!
  
  // Core Location Properties
  let locationManager =     CLLocationManager()
  let geocoder =            CLGeocoder()
  
  var location:             CLLocation?
  var placemark:            CLPlacemark?
  
  var lastLocationError:    Error?
  var lastGeocodingError:   Error?
  
  var isUpdating =          false
  var isPerformingGeocode = false
  
  // Core Data Properties
  var managedObjectContext: NSManagedObjectContext!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureButtonStyle()
    updateLabels()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navigationController?.isNavigationBarHidden = false
  }
  
  // MARK: - Private functions
  func showLocationServicesDisabledAlert() {
    let alert = UIAlertController(
      title: "Location Services Disabled",
      message: "Please enable location services for app in Settings",
      preferredStyle: .alert)
    
    let action = UIAlertAction(
      title: "OK",
      style: .default,
      handler:  nil)
    
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      tagButton.isHidden = false
      messageLabel.text = ""
      // Address
      if let placemark = placemark {
        addressLabel.text = formatAddress(from: placemark)
      } else if isPerformingGeocode {
        addressLabel.text = "Searching for Address..."
      } else if lastGeocodingError != nil {
        addressLabel.text = "Error Finding Address"
      } else {
        addressLabel.text = "No Address Found"
      }
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.isHidden = true
      // Message
      let statusMessage: String
      if let error = lastLocationError as NSError? {
        if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
          statusMessage = "Location Services Disabled"
        } else {
          statusMessage = "Error Getting Location"
        }
      } else if !CLLocationManager.locationServicesEnabled() {
        statusMessage = "Location Services Disabled"
      } else if isUpdating {
        statusMessage = "Searching..."
      } else {
        statusMessage = "Tap 'Get My Location' to Start"
      }
      messageLabel.text = statusMessage
    }
    configureGetButton()
  }
  
  func formatAddress(from: CLPlacemark) -> String {
    var line1 = ""
    if let tmp = placemark?.subThoroughfare {
      line1 += tmp + " "
    }
    
    if let tmp = placemark?.thoroughfare {
      line1 += tmp
    }
    
    var line2 = ""
    if let tmp = placemark?.locality {
      line2 += tmp + " "
    }
    
    if let tmp = placemark?.administrativeArea {
      line2 += tmp + " "
    }
    
    if let tmp = placemark?.postalCode {
      line2 += tmp
    }
    
    return line1 + "\n" + line2
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      isUpdating = true
    }
  }
  
  func stopLocationManager() {
    if isUpdating {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      isUpdating = false
    }
  }
  
  func configureButtonStyle() {
    tagButton.layer.cornerRadius = 8
    getButton.layer.cornerRadius = 8
  }
  
  func configureGetButton() {
    if isUpdating {
      getButton.setTitle("Stop", for: .normal)
    } else {
      getButton.setTitle("Get My Location", for: .normal)
    }
  }
  
  // MARK: - Actions
  @IBAction func getLocation() {
    if locationManager.authorizationStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    
    if locationManager.authorizationStatus == .restricted || locationManager.authorizationStatus == .denied {
      showLocationServicesDisabledAlert()
      return
    }
    
    if isUpdating {
      placemark = nil
      lastGeocodingError = nil
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      startLocationManager()
    }
    updateLabels()
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let location = location else { return }

    if segue.identifier == "TagLocation" {
      let controller = segue.destination as! LocationDetailViewController
      controller.coordinates = location.coordinate
      controller.placemark = placemark
      controller.managedObjectContext = managedObjectContext
    }
  }
}

// MARK: - Core Location delegate objects
extension CurrentLocationViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let newLocation = locations.last else { return }
    
    // Times are too close to compare
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    
    // Invalid accuracy so try again
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    // if new location is more useful than last... continue processing
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      lastLocationError = nil
      location = newLocation
      
      // if new lcoation is good enough to our conditions stop the location updates
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        stopLocationManager()
      }
      updateLabels()
      
      if !isPerformingGeocode {
        isPerformingGeocode = true
        geocoder.reverseGeocodeLocation(newLocation) { placemark, error in
          self.lastGeocodingError = error
          if error == nil, let places = placemark, !places.isEmpty {
            self.placemark = places.last!
          } else {
            self.placemark = nil
          }
          self.isPerformingGeocode = false
          self.updateLabels()
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if (error as NSError).code == CLError.locationUnknown.rawValue {
      return
    }
    lastLocationError = error
    stopLocationManager()
  }
}
