//
//  ViewController.swift
//  Photagrapher
//
//  Created by Richie Flores on 7/8/22.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {
  
  @IBOutlet weak var messageLabel:    UILabel!
  @IBOutlet weak var latitudeLabel:   UILabel!
  @IBOutlet weak var longitudeLabel:  UILabel!
  @IBOutlet weak var addressLabel:    UILabel!
  @IBOutlet weak var tagButton:       UIButton!
  @IBOutlet weak var getButton:       UIButton!
  
  // Core Location Managers
  let locationManager =     CLLocationManager()
  let geocoder =            CLGeocoder()
  
  var location:             CLLocation?
  var placemark:            CLPlacemark?
  
  var lastLocationError:    Error?
  var lastGeocodingError:   Error?
  
  var isUpdating =          false
  var isPerformingGeocode = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureButtonStyle()
    updateLabels()
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
    guard let location = location else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.isHidden = true
      
      var statusMessage: String
      if let error = lastLocationError as NSError? {
        if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
          statusMessage = "Location Services Disabled"
        } else {
          statusMessage = "Error receiving location"
        }
      } else if (!CLLocationManager.locationServicesEnabled()) {
        statusMessage = "Location Serviecs Disabled"
      } else if isUpdating {
        statusMessage = "Searching..."
        print("Searching for location...")
      } else {
        statusMessage = "Tap 'Get My Location' to Start"
      }
      messageLabel.text = statusMessage
      configureGetButton()
      return
    }

    latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
    tagButton.isHidden = false
    messageLabel.text = ""
    configureGetButton()
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
      print("Stopping search for location...")
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
    isUpdating ? getButton.setTitle("Stop Updating", for: .normal) : getButton.setTitle("Get My Location", for: .normal)
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
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      startLocationManager()
    }
    updateLabels()
  }
}

// MARK: - Core Location delegate objects
extension CurrentLocationViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let newLocation = locations.last else { return }
    print("LOCATION: \(newLocation)")
    
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
        print(">>> We're Done")
        stopLocationManager()
      }
      updateLabels()
      
      if !isPerformingGeocode {
        print(">>> Performing Geocode operations")
        isPerformingGeocode = true
        geocoder.reverseGeocodeLocation(newLocation) { placemark, error in
          if let error = error {
            print(">>> GEOCODING ERROR: \(error.localizedDescription)")
          }
          
          if let placemark = placemark {
            print("PLACEMARK: \(placemark)")
          }
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
