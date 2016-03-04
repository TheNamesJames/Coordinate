//
//  ViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 31/12/2015.
//  Copyright © 2015 James Wilkinson. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

public struct Member {
  let name: String
  let location: CLLocationCoordinate2D
}

class ViewController: UIViewController, CLLocationManagerDelegate, PreviewMemberListener {
  
  @IBOutlet weak var mapVCContainer: UIView!
  private var mapVC: MapViewController!
  var membersTableView: UITableView!
  private var membersTVC: MembersTableViewController!
  
  private var locationManager = CLLocationManager()
  var data: [Member]!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager.delegate = self
    if CLLocationManager.locationServicesEnabled() {
      print("Location services enabled")
      if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
        print("Requesting always status")
        self.locationManager.requestAlwaysAuthorization()
      }
    }
    
    self.membersTVC = self.storyboard!.instantiateViewControllerWithIdentifier("MembersTableViewController") as! MembersTableViewController
//    self.membersTVC.data = self.data
    self.membersTVC.mapView = self.mapVC.mapView
    self.membersTVC.addPreviewMemberListener(self.mapVC)
    self.membersTVC.addPreviewMemberListener(self)
    self.membersTableView = self.membersTVC.view as! UITableView
    self.view.addSubview(self.membersTableView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.membersTableView.frame = self.mapVCContainer.frame
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - CLLocationManagerDelegate
  
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
      self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      // TODO: Re-enable location updates
      self.locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError: \(error.description)")
    
    switch error.code {
    case CLError.LocationUnknown.rawValue:
      // Ignore error: Core Location will continue trying
      // TODO: show some onscreen notification
      break
      
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
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let newLocation = locations.last {
      print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
      
//TODO: Re-enable publishing location
//      let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
//      let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//      delegate.pubnubClient?.publish(message, toChannel: delegate.channel, withCompletion: { (status) -> Void in
//        print(status)
//      })
    }
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "EmbedMapSegue" {
      self.mapVC = segue.destinationViewController as! MapViewController
      self.mapVC.data = self.data
    }
  }
  
  // MARK: - PreviewMemberDelegate
  
  private var prePreviewTitle: String? = nil
  
  func previewMember(member: User?) {
    if let member = member {
      if prePreviewTitle == nil {
        prePreviewTitle = self.title
      }
      self.title = member.first!
    } else {
      if self.prePreviewTitle != nil {
        self.title = prePreviewTitle
        prePreviewTitle = nil
      }
    }
  }
}
