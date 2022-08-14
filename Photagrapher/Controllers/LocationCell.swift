//
//  LocationCell.swift
//  Photagrapher
//
//  Created by Richie Flores on 8/7/22.
//

import UIKit

class LocationCell: UITableViewCell {
  
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet weak var favoriteImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  // MARK: - Helper Methods
  func configure(for location: Location) {
//    TODO: Uncomment to set descriptionLabel to be actual description
    if location.locationDescription.isEmpty {
      descriptionLabel.text = "(No Description)"
    } else {
      descriptionLabel.text = location.locationDescription
    }
    
    //descriptionLabel.text = location.category
    if let placemark = location.placemark {
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
      addressLabel.text = text
    } else {
      addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
    }
    
    if location.isFavorite {
      favoriteImage.image = UIImage(systemName: "star.fill")
    } else {
      favoriteImage.isHidden = true 
    }
  }
}
