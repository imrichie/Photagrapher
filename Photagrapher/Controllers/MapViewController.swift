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
    if !locationManager.locations.isEmpty {
      showLocations()
    }
  }
  
  // MARK: - Bar Button Actions
  @IBAction func showUser(_ sender: Any) {
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    mapView.setRegion(region, animated: true)
  }
  
  @IBAction func showLocations() {
    print(">>> Showing Locations...")
    let region = region(for: locationManager.locations)
    mapView.setRegion(region, animated: true)
  }
  
  // MARK: - Helper methods
  func updateLocations() {
    mapView.removeAnnotations(locationManager.locations)
    let fetchRequest = NSFetchRequest<Location>(entityName: Constants.Entities.location)
    locationManager.locations = try! locationManager.managedObjectContext.fetch(fetchRequest)
    mapView.addAnnotations(locationManager.locations)
  }
  
  func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
    let region: MKCoordinateRegion

    switch annotations.count {
    case 0:
      region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

    case 1:
      let annotation = annotations[annotations.count - 1]
      region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

    default:
      var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
      var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)

      for annotation in annotations {
        topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
        topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
        bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
        bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
      }

      let center = CLLocationCoordinate2D(
        latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
        longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)

      let extraSpace = 1.1
      let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace, longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)

      region = MKCoordinateRegion(center: center, span: span)
    }

    return mapView.regionThatFits(region)
  }
}

extension MapViewController: MKMapViewDelegate {
  
}
