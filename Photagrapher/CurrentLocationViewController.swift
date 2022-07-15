//
//  ViewController.swift
//  Photagrapher
//
//  Created by Richie Flores on 7/8/22.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  
  let locationManager = CLLocationManager()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  // MARK: - Actions
  @IBAction func getLocation() {
    locationManager.delegate = self
    let authStatus = locationManager.authorizationStatus
    if authStatus == CLAuthorizationStatus.notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    print(">>> AUTH STATUS: \(authStatus)")
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
  }
}

// MARK: - Core Location delegate objects
extension CurrentLocationViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let newLocation = locations.last {
      print(">>> LOCATION: \(newLocation)")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(">>> LOCATION ERROR: \(error.localizedDescription)")
  }
}
