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

  
  let locationManager = CLLocationManager()
  var location: CLLocation?

  
  // MARK: - Actions
  @IBAction func getLocation() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
    
    let authStatus = locationManager.authorizationStatus
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    if authStatus == .denied || authStatus == .restricted {
      showLocationServicesDeniedAlert()
      return
    }
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
  
  
  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      tagButton.isHidden = false
      messageLabel.text = ""
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.isHidden = true
      messageLabel.text = "Tap 'get My Location' to Start"
    }
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
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")
    location = newLocation
    updateLabels()
  }

}
