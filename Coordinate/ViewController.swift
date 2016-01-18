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
import StatusBarNotificationCenter //TODO: Replace Status bar notification w/ custom drop-down view from Navigation bar

public struct Member {
  let name: String
  let location: CLLocationCoordinate2D
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MembersViewControllerDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  private var locationManager = CLLocationManager()
  private var showingStatusNotification = false
  
  var data: [Member]

  required init?(coder aDecoder: NSCoder) {
    let john = Member(name: "John", location: CLLocationCoordinate2D(latitude: 51.515372, longitude: -0.141880))
    let joe = Member(name: "Joe", location: CLLocationCoordinate2D(latitude: 51.521958, longitude: -0.046652))
    let bob = Member(name: "Bob", location: CLLocationCoordinate2D(latitude: 51.522525, longitude: -0.041899))
    data = [john, joe, bob]
    
    super.init(coder: aDecoder)
  }
  
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
    
    var annotations: [MKAnnotation] = []
    for member in data {
      let annotation = MKPointAnnotation()
      annotation.coordinate = member.location
      annotation.title = member.name
      annotations.append(annotation)
    }
    self.mapView.addAnnotations(annotations)
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
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if showingStatusNotification {
      StatusBarNotificationCenter.dismissNotificationWithCompletion(nil);
      showingStatusNotification = false
    }
    
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
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("MemberPinAnnotation")
    if annotationView == nil {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MemberPinAnnotation")
      annotationView!.centerOffset = CGPointMake(10, -20)
    }
    
    annotationView!.annotation = annotation
    
    return annotationView
  }
  
  
  // MARK: - Navigation
  
  @IBAction func membersButtonPressed(sender: AnyObject) {
    self.performSegueWithIdentifier("ShowMembersSegue", sender: sender)
  }

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowMembersSegue" {
      let destinationVC = segue.destinationViewController as! MembersViewController
      destinationVC.data = data
      destinationVC.delegate = self
    }
  }

  // MARK: - MembersViewControllerDelegate
  
  private var prePreviewMapRect: MKMapRect? = nil
  
  func previewMemberLocation(member: Member?) {
    if let member = member {
      if prePreviewMapRect == nil {
        prePreviewMapRect = self.mapView.visibleMapRect
      }
      
      var region = self.mapView.region;
      let span = MKCoordinateSpanMake(0.005, 0.005);
      
      region.center = member.location;
      
      region.span = span;
      
//      self.mapView.setRegion(region, animated: true)
      MKMapView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.mapView.setRegion(region, animated: true)
        }, completion: nil)
    } else {
      if self.prePreviewMapRect != nil {
        mapView.setVisibleMapRect(self.prePreviewMapRect!, animated:true)
        prePreviewMapRect = nil
      }
    }
  }
}
