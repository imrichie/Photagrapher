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
  }
}
