//
//  ViewController.swift
//  MyLocation
//
//  Created by Seok Jun Noh on 10/18/21.
//

import UIKit
import CoreLocation


class CurrentLocationViewController: UIViewController {

  @IBOutlet var messageLabel: UILabel!
  @IBOutlet var latitudeLabel: UILabel!
  @IBOutlet var longitudeLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var tagButton: UIButton!
  @IBOutlet var getButton: UIButton!

  @IBOutlet var imageView: UIImageView!
  
  let locationManager = CLLocationManager()
  var location: CLLocation?
  var updatingLocation = false
  var lastLocationError: Error?
  
  let geocoder = CLGeocoder()
  var placemark: CLPlacemark?
  var performingReverseGeocoding = false
  var lastGeocodingError: Error?
  
  // MARK: - Actions
  @IBAction func getLocation() {
    let authStatus = locationManager.authorizationStatus
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }

    if authStatus == .denied || authStatus == .restricted {
      showLocationServicesDeniedAlert()
      return
    }

    if updatingLocation {
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      startLocationManager()
    }
    updateLabels()
    
//    print("1")
//    var i: Int = 0
//    DispatchQueue.global().async {
//      for n in 0...10000000 {
//        i = i + n
//      }
//      print("2")
//      DispatchQueue.main.async {
//        self.messageLabel.text = "\(i)"
//        print("3")
//      }
//      print("4")
//    }
//    print("5")
    
//    DispatchQueue.global().async {
//      let url = URL(string: "https://techcrunch.com/wp-content/uploads/2021/10/GettyImages-1342835899.jpg?w=1390&crop=1")!
//      if let data = try? Data(contentsOf: url) {
//        DispatchQueue.main.async { [weak self] in
//          self?.imageView.image = UIImage(data: data)
//        }
//      }
//    }
//    DispatchQueue.global().async {
//      let url = URL(string: "https://techcrunch.com/wp-content/uploads/2021/10/GettyImages-1342835890.jpg?w=1390&crop=1")!
//      if let data = try? Data(contentsOf: url) {
//        DispatchQueue.main.async { [weak self] in
//          self?.imageView.image = UIImage(data: data)
//        }
//      }
//    }
//    DispatchQueue.global().async {
//      let url = URL(string: "https://techcrunch.com/wp-content/uploads/2021/10/GettyImages-1342835891.jpg?w=1390&crop=1")!
//      if let data = try? Data(contentsOf: url) {
//        DispatchQueue.main.async { [weak self] in
//          self?.imageView.image = UIImage(data: data)
//        }
//      }
//    }
  }
  
  
  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      tagButton.isHidden = false
      messageLabel.text = ""
      
      if let placemark = placemark {
        addressLabel.text = string(from: placemark)
      } else if performingReverseGeocoding {
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
      
      let statusMessage: String
      if let error = lastLocationError as NSError? {
        if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
          statusMessage = "Location Services Disabled"
        } else {
          statusMessage = "Error Getting Location"
        }
      } else if !CLLocationManager.locationServicesEnabled() {
        statusMessage = "Locatino Services Disabled"
      } else if updatingLocation {
        statusMessage = "Searching..."
      } else {
        statusMessage = "Tap 'Get My Location' to Start"
      }
      messageLabel.text = statusMessage
    }
    configureGetButton()
  }
  
  
  // MARK: - Helper Methods
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(
      title: "Location Services Disabled",
      message: "Please enable location services for this app in Settings.",
      preferredStyle: .alert)

    let okAction = UIAlertAction(
      title: "OK",
      style: .default,
      handler: nil)
    alert.addAction(okAction)

    present(alert, animated: true, completion: nil)
  }
  
  func configureGetButton() {
    if updatingLocation {
      getButton.setTitle("Stop", for: .normal)
    } else {
      getButton.setTitle("Get My Location", for: .normal)
    }
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updatingLocation = true
    }
  }
  
  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }
  
  
  func string(from placemark: CLPlacemark) -> String {
    // 1
    var line1 = ""
    // 2
    if let tmp = placemark.subThoroughfare {
      line1 += tmp + " "
    }
    // 3
    if let tmp = placemark.thoroughfare {
      line1 += tmp
    }
    // 4
    var line2 = ""
    if let tmp = placemark.locality {
      line2 += tmp + " "
    }
    if let tmp = placemark.administrativeArea {
      line2 += tmp + " "
    }
    if let tmp = placemark.postalCode {
      line2 += tmp
    }
    // 5
    return line1 + "\n" + line2
  }

  
  // MARK:- ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
  }
}

extension CurrentLocationViewController: CLLocationManagerDelegate {
  // MARK: - CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError \(error.localizedDescription)")
    
    if (error as NSError).code == CLError.locationUnknown.rawValue {
      return
    }
    lastLocationError = error
    stopLocationManager()
    updateLabels()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")
    // 1
    if newLocation.timestamp.timeIntervalSinceNow < -5  {
      return
    }
    
    // 2
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    // 3
    // Note that a larger accuracy value means LESS accurate
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      // 4
      lastLocationError = nil
      location = newLocation
      
      // 5
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        print("*** We're done!")
        stopLocationManager()
      }
    }
    updateLabels()
    
    if !performingReverseGeocoding {
      print("*** Going to geocode")

      performingReverseGeocoding = true

      // This kind of escaping closures for functions that perform asynchronous work and invoke the closure as a callback.
      geocoder.reverseGeocodeLocation(newLocation) {placemarks, error in
        self.lastGeocodingError = error
        if error == nil, let places = placemarks, !places.isEmpty {
          self.placemark = places.last!
        } else {
          self.placemark = nil
        }
        
        self.performingReverseGeocoding = false
        self.updateLabels()
      }
    }
  }
}
