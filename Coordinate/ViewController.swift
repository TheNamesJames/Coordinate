//
//  ViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 31/12/2015.
//  Copyright © 2015 James Wilkinson. All rights reserved.
//

import UIKit
import CoreLocation
import StatusBarNotificationCenter //TODO: Replace Status bar notification w/ custom drop-down view from Navigation bar

class ViewController: UIViewController, CLLocationManagerDelegate {
  
  private var locationManager = CLLocationManager()
  private var showingStatusNotification = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    print("Hello World!")
    self.locationManager.delegate = self
    if CLLocationManager.locationServicesEnabled() {
      print("Location services enabled")
      if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
        print("Requesting always status")
        self.locationManager.requestAlwaysAuthorization()
      }
    }
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
      //TODO: Disable PubNub sending??
      break
      
    case .AuthorizedWhenInUse:
      fallthrough
    
    case .AuthorizedAlways:
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
// TODO: Re-enable location updates
//        self.locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError: \(error.description)")
    
    switch error.code {
    case CLError.LocationUnknown.rawValue:
      // Ignore error: Core Location will continue trying
      if !showingStatusNotification {
        var sbncCenterConfig = NotificationCenterConfiguration(baseWindow: self.view.window!)
        sbncCenterConfig.level = UIWindowLevelStatusBar
        sbncCenterConfig.dismissible = false
        var sbncLabelConfig = NotificationLabelConfiguration()
        sbncLabelConfig.backgroundColor = UIColor.redColor()
        sbncLabelConfig.textColor = UIColor.whiteColor()
        StatusBarNotificationCenter.showStatusBarNotificationWithMessage("Unable to get your location", withNotificationCenterConfiguration: sbncCenterConfig, andNotificationLabelConfiguration: sbncLabelConfig)
        showingStatusNotification = true
      }

      
    case CLError.Denied.rawValue:
      let alert = UIAlertController(title: "Error", message: "Location Services Disabled", preferredStyle: .Alert)
      alert.message = "Turn on Location Services in Settings > Coordinate to allow Coordinate to use your current location"
      
      if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
          UIApplication.sharedApplication().openURL(url)
        }))
      }
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: nil)
      
      
    default: break
    }
    
    
    
    if error.code == CLError.Denied.rawValue {
      let alert = UIAlertController(title: "Error", message: "Location Services Disabled", preferredStyle: .Alert)
      alert.message = "Turn on Location Services in Settings > Coordinate to allow Coordinate to use your current location"
      
      if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
          UIApplication.sharedApplication().openURL(url)
        }))
      }
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if showingStatusNotification {
      StatusBarNotificationCenter.dismissNotificationWithCompletion(nil);
      showingStatusNotification = false
    }
    
    if let newLocation = locations.last {
      print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
//      let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
//      let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//      delegate.pubnubClient?.publish(message, toChannel: delegate.channel, withCompletion: { (status) -> Void in
//        print(status)
//      })
    }
  }
}

