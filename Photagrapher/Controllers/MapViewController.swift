//
//  MapViewController.swift
//  Photagrapher
//
//  Created by Richie Flores on 8/13/22.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
  var locationManager: LocationManager!
  
  @IBOutlet weak var mapView: MKMapView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLocations()
  }
  
  // MARK: - Bar Button Actions
  @IBAction func showUser(_ sender: Any) {
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    mapView.setRegion(region, animated: true)
  }
  
  @IBAction func showLocations(_ sender: Any) {
    print(">>> Showing Locations...")
  }
  
  // MARK: - Helper methods
  func updateLocations() {
    mapView.removeAnnotations(locationManager.locations)
    let fetchRequest = NSFetchRequest<Location>(entityName: Constants.Entities.location)
    
    do {
      locationManager.locations = try locationManager.managedObjectContext.fetch(fetchRequest)
    } catch {
      fatalError(">>> FETCHING ERROR: \(error.localizedDescription)")
    }
    mapView.addAnnotations(locationManager.locations)
  }
}

extension MapViewController: MKMapViewDelegate {
  
}
