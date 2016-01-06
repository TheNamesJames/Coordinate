//
//  ViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 31/12/2015.
//  Copyright © 2015 James Wilkinson. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
  
  private var locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    print("Hello World!")
    self.locationManager.delegate = self
    if CLLocationManager.locationServicesEnabled() {
      print("location services enabled")
    }
    self.locationManager.requestAlwaysAuthorization()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: CLLocationManagerDelegate

  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    switch status {
    case .NotDetermined: break
    
    case .Restricted:
      fallthrough
    
    case .Denied:
      let alert = UIAlertController(title: "Error", message: "Failed to Get Your Location", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    
    case .AuthorizedAlways:
      fallthrough
    
    case .AuthorizedAlways:
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
      
    default: break
    }
    
//    if (status == .AuthorizedAlways) || (status == .AuthorizedWhenInUse) {
//      self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//      self.locationManager.startUpdatingLocation()
//    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError: \(error.description)")
    let alert = UIAlertController(title: "Error", message: "Failed to Get Your Location", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let newLocation = locations.last {
      print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
      let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
      let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
      delegate.pubnubClient?.publish(message, toChannel: delegate.channel, withCompletion: { (status) -> Void in
        print(status)
      })
    }
  }
}

