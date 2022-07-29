//
//  LocationDetailViewController.swift
//  Photagrapher
//
//  Created by Richie Flores on 7/28/22.
//

import UIKit

class LocationDetailViewController: UITableViewController {
  
  @IBOutlet var descriptionTextView: UITextView!
  @IBOutlet var categoryLabel: UILabel!
  @IBOutlet var latitudeLabel: UILabel!
  @IBOutlet var longitutudeLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  // MARK: - Actions
  @IBAction func done() {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cancel() {
    navigationController?.popViewController(animated: true)
  }
}
