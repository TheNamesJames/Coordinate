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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MembersViewControllerDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  private var locationManager = CLLocationManager()
  
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
    
    let userTrackingButton = MKUserTrackingBarButtonItem(mapView: self.mapView)
    self.toolbarItems = [userTrackingButton]
    
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
    if segue.identifier == "TestShowMembers" {
      let destinationVC = segue.destinationViewController as! MembersTableViewController
      destinationVC.data = self.data
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

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.data.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell", forIndexPath: indexPath) as! MemberTableViewCell
    
    cell.textLabel!.text = self.data[indexPath.row].name
    cell.setContactColour({
      switch indexPath.row % 3 {
      case 0:
        return UIColor(red: 211/255, green: 84/255, blue: 0/255, alpha: 0.5)
      case 1:
        return UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 0.5)
      case 2:
        return UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 0.5)
      default:
        return UIColor.clearColor()
      }
    }())
    
    return cell
  }
}
