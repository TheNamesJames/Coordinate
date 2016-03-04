//
//  TeamViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 02/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class TeamViewController: UIViewController, CLLocationManagerDelegate, PreviewMemberListener {
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/")
  
  @IBOutlet var simulate: UIBarButtonItem!
  
  @IBOutlet weak var mapVCContainer: UIView!
  private var mapVC: TeamMapViewController!
  var membersTableView: UITableView!
  private var membersTVC: TeamMembersTableViewController!
  
  private var locationManager = CLLocationManager()
  var team: Team!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    //    self.locationManager.delegate = self
    //    if CLLocationManager.locationServicesEnabled() {
    //      print("Location services enabled")
    //      if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
    //        print("Requesting always status")
    //        self.locationManager.requestAlwaysAuthorization()
    //      }
    //    }
    
    
    self.membersTVC = self.storyboard!.instantiateViewControllerWithIdentifier("TeamMembersTableViewController") as! TeamMembersTableViewController
    self.membersTVC.team = self.team
    self.membersTVC.mapView = self.mapVC.mapView
    self.membersTVC.addPreviewMemberListener(self.mapVC)
    self.membersTVC.addPreviewMemberListener(self)
    self.membersTableView = self.membersTVC.view as! UITableView
    self.view.addSubview(self.membersTableView)
    
//    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      self.navigationItem.rightBarButtonItem = self.simulate
//    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.membersTableView.frame = self.mapVCContainer.frame
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //  // MARK: - CLLocationManagerDelegate
  //
  //  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
  //    switch status {
  //    case .NotDetermined: break
  //
  //    case .Restricted:
  //      fallthrough
  //
  //    case .Denied:
  //      //TODO: Disable PubNub sending??
  //      break
  //
  //    case .AuthorizedWhenInUse:
  //      fallthrough
  //
  //    case .AuthorizedAlways:
  //      self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
  //      // TODO: Re-enable location updates
  //      self.locationManager.startUpdatingLocation()
  //    }
  //  }
  //
  //  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
  //    print("didFailWithError: \(error.description)")
  //
  //    switch error.code {
  //    case CLError.LocationUnknown.rawValue:
  //      // Ignore error: Core Location will continue trying
  //      // TODO: show some onscreen notification
  //      break
  //
  //    case CLError.Denied.rawValue:
  //      let alert = UIAlertController(title: "Error", message: "Location Services Disabled", preferredStyle: .Alert)
  //      alert.message = "Turn on Location Services in Settings > Coordinate to allow Coordinate to use your current location"
  //
  //      if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
  //        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
  //          UIApplication.sharedApplication().openURL(url)
  //        }))
  //      }
  //      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
  //
  //      self.presentViewController(alert, animated: true, completion: nil)
  //
  //
  //    default: break
  //    }
  //  }
  //
  //  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  //    if let newLocation = locations.last {
  //      print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
  //
  //      //TODO: Re-enable publishing location
  //      //      let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
  //      //      let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
  //      //      delegate.pubnubClient?.publish(message, toChannel: delegate.channel, withCompletion: { (status) -> Void in
  //      //        print(status)
  //      //      })
  //    }
  //  }
  
  
  // MARK: - Navigation
  @IBAction func doneSimulating(segue: UIStoryboardSegue) {
    
  }
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "EmbedMapSegue" {
      self.mapVC = segue.destinationViewController as! TeamMapViewController
      self.mapVC.team = self.team
    }
    if segue.identifier == "SimulatePopover" {
      let nav = segue.destinationViewController as! UINavigationController
      let simVC = nav.topViewController as! SimulatorViewController
      simVC.team = self.team
    }
  }
  
  // MARK: - PreviewMemberDelegate
  
  private var prePreviewTitle: String? = nil
  
  func previewMember(member: Team.Member?) {
    if let member = member {
      if prePreviewTitle == nil {
        prePreviewTitle = self.title
      }
      self.title = member.username
    } else {
      if self.prePreviewTitle != nil {
        self.title = prePreviewTitle
        prePreviewTitle = nil
      }
    }
  }
  
}
