//
//  Constants.swift
//  Photagrapher
//
//  Created by Richie Flores on 8/2/22.
//

import Foundation

struct Constants {
  struct DataManager {
    static let cacheName: String = "Locations"
    static let sectionNameKeyPath: String = "category"
  }
  
  struct CellNames {
    static let locationCellNibName: String = "LocationCell"
    static let locationCell: String = "LocationCell"
    static let defaultCell: String = "DefaultCell"
  }
  
  struct Entities {
    static let location: String = "Location"
  }
  
  struct SegueNames {
    static let editLocation: String = "EditLocation"
  }
  
  struct Annotations {
    static let identifier: String = "Location"
  }
}
