//
//  LocationDetailViewController.swift
//  Photagrapher
//
//  Created by Richie Flores on 7/28/22.
//  Property of AppLimited Software LLC
//

import UIKit
import CoreLocation
import CoreData

// MARK: - Lazy Objects
private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  return formatter
}()

class LocationDetailViewController: UITableViewController {
  // Outlets
  @IBOutlet var descriptionTextView:  UITextView!
  @IBOutlet var categoryLabel:        UILabel!
  
  @IBOutlet var addPhotoLabel:        UILabel!
  @IBOutlet var imageView:            UIImageView!
  
  @IBOutlet var latitudeLabel:        UILabel!
  @IBOutlet var longitutudeLabel:     UILabel!
  @IBOutlet var addressLabel:         UILabel!
  @IBOutlet var dateLabel:            UILabel!
  
  // Data for controls
  var descriptionText: String = ""
  var categoryName: String = "No Category"
  var image: UIImage?
  var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var date: Date = Date()
  
  // Core Data
  var locationManager: LocationManager!
  
  // property observer
  var locationToEdit: Location? {
    didSet {
      if let location = locationToEdit {
        coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        placemark = location.placemark
        categoryName = location.category
        date = location.date
        descriptionText = location.locationDescription
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    descriptionTextView.text = descriptionText
    categoryLabel.text = categoryName
    
    latitudeLabel.text = String(format: "%.8f", coordinates.latitude)
    longitutudeLabel.text = String(format: "%.8f", coordinates.longitude)
    
    if let placemark = placemark {
      addressLabel.text = formatAddress(from: placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    dateLabel.text = format(date: date)
  }
  
  // MARK: - Private Methods
  
  func show(image: UIImage) {
    imageView.image = image
    imageView.isHidden = false
    addPhotoLabel.text = ""
  }
  
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
      text += temp + ", "
    }
    
    if let temp = placemark?.postalCode {
      text += temp + " "
    }
    
    if let temp = placemark?.country {
      text += temp
    }
    return text
  }
  
  func format(date: Date) -> String {
    return dateFormatter.string(from: date)
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destination as! CategoryPickerViewController
      controller.selectedCategoryName = categoryName
    }
  }
  
  @IBAction func didPickCategory(unwindSegue: UIStoryboardSegue) {
    let controller = unwindSegue.source as! CategoryPickerViewController
    categoryName = controller.selectedCategoryName
    categoryLabel.text = categoryName
  }
  
  // MARK: - Actions
  @IBAction func done() {
    
    let location: Location
    if let locationToEdit = locationToEdit {
      location = locationToEdit
      print(">>> Location Edited!")
    } else {
      location = Location(context: locationManager.managedObjectContext)
      print(">>> New Location Created!")
    }
    
    // set properties
    location.longitude = coordinates.longitude
    location.latitude = coordinates.latitude
    location.locationDescription = descriptionTextView.text
    location.category = categoryName
    location.date = date
    location.placemark = placemark
    
    // ask managedObjectContext to save to CoreData
    do {
      try locationManager.managedObjectContext.save()
      print(">>> Saved to Core Data")
      navigationController?.popViewController(animated: true)
    } catch {
      fatalError(">>> ERROR: \(error)")
    }
  }
  
  @IBAction func cancel() {
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Table View Delegates
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    // displays keyboard for the description text view
    if indexPath.section == 0 && indexPath.row == 0 {
      descriptionTextView.becomeFirstResponder()
      // Image Picker
    } else if indexPath.section == 1 && indexPath.row == 0 {
      pickPhoto()
    }
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if indexPath.section == 0 || indexPath.section == 1 {
      return indexPath
    } else {
      return nil
    }
  }
  
  // MARK: - Helper Functions
  func takePhotoWithCamera() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.allowsEditing = true
    imagePicker.delegate = self
    present(imagePicker, animated: true, completion: nil)
  }
  
  func pickPhoto() {
    if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
      showPhotoMenu()
    } else {
      chooseFromLibrary()
    }
  }
  
  func chooseFromLibrary() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.allowsEditing = true
    imagePicker.delegate = self
    present(imagePicker, animated: true)
  }
  
  func showPhotoMenu() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
    alert.addAction(actionCancel)
    
    // TODO: Add handler to call takePhotoWithCamera() when testing on real device
    let actionPhoto = UIAlertAction(title: "Take Photo", style: .default)
    alert.addAction(actionPhoto)
    
    let actionLibrary = UIAlertAction(title: "Choose from Library", style: .default) { _ in
      self.chooseFromLibrary()
    }
    alert.addAction(actionLibrary)
    
    present(alert, animated: true)
  }
}

extension LocationDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    image = info[.editedImage] as? UIImage
    if let theImage = image {
      show(image: theImage)
    }
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}
