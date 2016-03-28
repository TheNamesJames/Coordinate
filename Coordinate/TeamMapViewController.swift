//
//  TeamMapViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 23/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class TeamMapViewController: UIViewController, PreviewMemberListener {
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBOutlet var centerPin: UIImageView!
  private var settingWaypointForMemberAnnotation: MemberAnnotation? = nil {
    didSet {
      if let _ = settingWaypointForMemberAnnotation {
        self.centerPin.hidden = false
      } else {
        self.centerPin.hidden = true
      }
    }
  }
  private var polylineForTemporaryWaypoint: MKPolyline? = nil {
    willSet {
      if let polyline = polylineForTemporaryWaypoint {
        self.mapView.removeOverlay(polyline)
      }
    }
    didSet {
      if let polyline = polylineForTemporaryWaypoint {
        self.mapView.addOverlay(polyline)
      }
    }
  }
  
  @IBAction func temporaryWaypointTapped(sender: UITapGestureRecognizer) {
//    let waypoint = WaypointAnnotation(associatedMember: self.settingWaypointForMemberAnnotation)
//    waypoint.coordinate = self.mapView.centerCoordinate
    let member = self.settingWaypointForMemberAnnotation!.title!
//    waypoint.title = "Sending \(member) here"
//    self.mapView.addAnnotation(waypoint)
    
    let dictionary = ["lat" : self.mapView.centerCoordinate.latitude, "lon" : self.mapView.centerCoordinate.longitude]
    self.waypointRef!.childByAppendingPath("\(member)").setValue(dictionary)
    
    self.polylineForTemporaryWaypoint = nil
    self.settingWaypointForMemberAnnotation = nil
  }
  
  var waypointRef: Firebase? {
    willSet {
      self.waypointRef?.removeAllObservers()
    }
    didSet {
      self.waypointRef?.observeEventType(.ChildAdded, withBlock: waypointAdded)
      self.waypointRef?.observeEventType(.ChildChanged, withBlock: waypointAdded)
      self.waypointRef?.observeEventType(.ChildRemoved, withBlock: waypointRemoved)
    }
  }
  
  func waypointAdded(snap: FDataSnapshot!) {
    let username = snap.key
    guard let coordinateDictionary = snap.value as? NSDictionary else {
      return
    }
//    let coordinateDictionary = snap.value as! NSDictionary
    let lat = coordinateDictionary["lat"] as! Double
    let lon = coordinateDictionary["lon"] as! Double
    
    let index = self.mapView.annotations.indexOf({ $0.title! == username })
    
    // Remove waypoint for this user if it exists already
    for annotation in self.mapView.annotations {
      if let annotation = annotation as? WaypointAnnotation {
        if annotation.associatedMember?.title == username {
          self.mapView.removeAnnotation(annotation)
        }
      }
    }
    
    if let index = index {
      let userAnnotation = self.mapView.annotations[index] as! MemberAnnotation

      let annotation = WaypointAnnotation(associatedMember: userAnnotation)
      annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      annotation.title = "Sending \(username) here"
      
      self.mapView.addAnnotation(annotation)
    }

  }
  
  func waypointRemoved(snap: FDataSnapshot!) {
    let username = snap.key
    
    // Remove waypoint for this user if it exists already
    for annotation in self.mapView.annotations {
      if let annotation = annotation as? WaypointAnnotation {
        if annotation.associatedMember?.title == username {
          self.mapView.removeAnnotation(annotation)
        }
      }
    }
  }

  
  var teamRef: Firebase? {
    willSet {
      self.teamRef?.removeAllObservers()
    }
    didSet {
      self.teamRef?.observeEventType(.ChildAdded, withBlock: memberAdded)
      self.teamRef?.observeEventType(.ChildRemoved, withBlock: memberRemoved)
    }
  }
  
  func memberRemoved(snap: FDataSnapshot!) {
    let username = snap.key
    
    snap.ref.root.childByAppendingPath("locations/\(self.team!.id)/\(username)").removeAllObservers()
    waypointRef!.childByAppendingPath("\(username)").removeAllObservers()
    
    // TODO: remove pin if member removed
  }
  
  func memberAdded(snap: FDataSnapshot!) {
    let username = snap.key
    
    // If member is not currentMember, add pin annotation
    if username != self.team!.currentMember.username {
      snap.ref.root.childByAppendingPath("locations/\(self.team!.id)/\(username)").queryLimitedToLast(1).observeEventType(.ChildAdded, withBlock: updateMemberLocation)
    }
    
  }
  
  func updateMemberLocation(snap: FDataSnapshot!) {
    let username = snap.ref.parent.key
//    print("member \(username) updated location")
    let dictionary = snap.value as! [String:Double]
    
    guard let lat = dictionary["lat"],
      let lon = dictionary["lon"] else {
        print("WARNING: Latest location update \(snap.key) has no lat/lon value")
        return
    }
    
    // 3: Add/update annotation for that user
    let index = self.mapView.annotations.indexOf({ $0.title! == username })
    if let index = index {
      let userAnnotation = self.mapView.annotations[index] as! MKPointAnnotation
      userAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      // remove annotation & re-add??
    } else {
      let annotation = MemberAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      annotation.title = username
      //          annotation.subtitle = first & last?? OR time??
      self.mapView.addAnnotation(annotation)
    }
    
    if self.currentlyPreviewingMember?.username == username {
      self.previewMember(self.currentlyPreviewingMember)
    }
    
    waypointRef!.childByAppendingPath("\(username)").observeSingleEventOfType(.Value, withBlock: waypointAdded)
    // TODO: Update waypoint if changed
//    waypointRef!.childByAppendingPath("\(username)").observeEventType(.ChildChanged, withBlock: waypointChanged)
  }
  
  var team: Team? {
    didSet {
      if let team = self.team {
        self.teamRef = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/teams/\(team.id)/members")
        self.waypointRef = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/waypoints/\(team.id)/")
      } else {
        self.teamRef = nil
        self.waypointRef = nil
      }
    }
  }
  
  private var locationManager = CLLocationManager() {
    didSet{
      print("didSet")
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    self.locationManager.delegate = self
//    if CLLocationManager.locationServicesEnabled() {
//      print("Location services enabled")
//      if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
//        print("Requesting always status")
//        CLLocationManager().requestAlwaysAuthorization()
//      }
//    }
    
    self.centerPin.alpha = 0
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
  // MARK: - PreviewMemberDelegate
  
  func locateSelf() {
//    self.previewMember(nil)
    guard CLLocationManager.locationServicesEnabled() else {
      let alert = UIAlertController(title: "Location services disabled", message: "We need location services enabled to be able to show your location", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
      return
    }
    
    switch CLLocationManager.authorizationStatus() {
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      self.mapView.setUserTrackingMode(.Follow, animated: true)
      
    default: // .Restricted, .Denied, .NotDetermined
      let alert = UIAlertController(title: "Location services denied", message: "We need location services enabled to be able to show your location", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "Settings", style: .Cancel, handler: { (action: UIAlertAction) in
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
    
  }

//  private var prePreviewMapRect: MKMapRect? = nil
  private var currentlyPreviewingMember: Team.Member?
  
  func previewMember(member: Team.Member?) {
    self.currentlyPreviewingMember = member
    
    if let member = member {
//      if prePreviewMapRect == nil {
//        prePreviewMapRect = self.mapView.visibleMapRect
//      }
      
      var region = self.mapView.region;
      let span = MKCoordinateSpanMake(0.005, 0.005);
      
      // FIXME: Should restructure to store location directly in Member??
      self.mapView.annotations.forEach({ (annotation: MKAnnotation) -> () in
        if annotation.title! == member.username {
          region.center = annotation.coordinate
        }
      })
      
      region.span = span;
      
      MKMapView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.mapView.setRegion(region, animated: true)
        }, completion: nil)
    }
//    else {
//      if self.prePreviewMapRect != nil {
//        mapView.setVisibleMapRect(self.prePreviewMapRect!, animated:true)
//        prePreviewMapRect = nil
//      }
//    }
  }
  
}

extension TeamMapViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation === mapView.userLocation {
      return nil
    }
    
    var annotationView: MKAnnotationView!
    switch annotation {
    case let annotation as MemberAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("MemberPinAnnotation")
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MemberPinAnnotation")
        annotationView.centerOffset = CGPointMake(10, -20)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TeamMapViewController.longPressed(_:)))
        longPress.delegate = self
        longPress.delaysTouchesBegan = false
        longPress.cancelsTouchesInView = false
        annotationView.addGestureRecognizer(longPress)
      } else {
        annotationView.annotation = annotation
      }
//      annotationView.draggable = true
      
      annotationView.canShowCallout = true
      
    case is WaypointAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("WaypointPinAnnotation")
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "WaypointPinAnnotation")
        annotationView!.centerOffset = CGPointMake(10, -50)
        (annotationView! as! MKPinAnnotationView).pinTintColor = UIColor.greenColor()
        
        let tick = UIButton(type: .ContactAdd)
        annotationView.rightCalloutAccessoryView = tick
        
        let cross = UIButton(type: .InfoDark)
        annotationView.leftCalloutAccessoryView = cross
        
        annotationView!.draggable = true
        annotationView.canShowCallout = true
      } else {
        annotationView!.annotation = annotation
      }

      
    default:
      fatalError("unknown annotation type")
    }
    
    return annotationView
  }
  
  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    if let _ = self.settingWaypointForMemberAnnotation {
      self.centerPin.alpha = 0.7
    }
  }
  
  func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if let _ = self.settingWaypointForMemberAnnotation {
      self.centerPin.alpha = 0.9
      
      var coords = [self.settingWaypointForMemberAnnotation!.coordinate, self.mapView.centerCoordinate]
      self.polylineForTemporaryWaypoint = MKPolyline(coordinates: &coords, count: 2)
      // TODO: (re)draw dotted line from member to here
    }
  }
  
  func longPressed(sender: UILongPressGestureRecognizer) {
    if sender.state == .Began {
      let pinAnnotation = sender.view as! MKPinAnnotationView
      pinAnnotation.selected = false
      self.settingWaypointForMemberAnnotation = (pinAnnotation.annotation as! MemberAnnotation)
      
      // Remove other waypoint(s) for this member
      for annotation in self.mapView.annotations {
        if let annotation = annotation as? WaypointAnnotation {
          if annotation.associatedMember == self.settingWaypointForMemberAnnotation {
            self.mapView.removeAnnotation(annotation)
          }
        }
      }
      
      var coords = [self.settingWaypointForMemberAnnotation!.coordinate, self.mapView.centerCoordinate]
      self.polylineForTemporaryWaypoint = MKPolyline(coordinates: &coords, count: 2)
      
      self.centerPin.alpha = 0.9
      
      
//      UIView.animateWithDuration(0.1, animations: { () -> Void in
//        self.centerPin.alpha = 1
//      })
      
//      let waypoint = WaypointAnnotation()
//      let point = sender.locationInView(self.mapView)
//      waypoint.coordinate = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
//      self.mapView.addAnnotation(waypoint)
      
//      let waypointAnnotation = self.mapView.viewForAnnotation(waypoint)!
//      waypointAnnotation.selected = true
//      waypointAnnotation.setDragState(.Starting, animated: true)
    }
    if sender.state == .Changed {
//      let pinAnnotation = sender.view as! MKPinAnnotationView
//      pinAnnotation.selected = false
      
//      print(sender.locationInView(self.mapView))
    }
  }
  
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = UIColor.blueColor()
      polylineRenderer.lineWidth = 5
      return polylineRenderer
//    }
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
    switch view.annotation {
    // Dragging member pin: Add 'placeholder' pin to take this one's place we move it
    case let annotation as MemberAnnotation:
      if oldState == .None {
        for a in self.mapView.annotations {
          if let a = a as? WaypointAnnotation {
            if a.isTemporary {
              self.mapView.removeAnnotation(a)
            }
          }
        }
        
        // Create Member annotation to replace this one
        let placeholder = MemberAnnotation()
        placeholder.coordinate = annotation.coordinate
        placeholder.title = "Move \(annotation.title) here?"
//        self.mapView.addAnnotation(placeholder)
        
        (view as! MKPinAnnotationView).pinTintColor = UIColor.blueColor()
        view.canShowCallout = true
      }
      
    case let annotation as WaypointAnnotation:
      print("Waypoint annotation dragged")
      
    default:
      print("dragging unexpected annotation: \(view.annotation)")
    }
  }
}

extension TeamMapViewController : UIGestureRecognizerDelegate {
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if let _ = otherGestureRecognizer as? UIPanGestureRecognizer {
      return false
    }
    
    return false
  }
}

class MemberAnnotation: MKPointAnnotation {
}

class WaypointAnnotation: MKPointAnnotation {
  let associatedMember: MemberAnnotation?
  var isTemporary = false
  
  convenience override init() {
    self.init(associatedMember: nil)
  }
  init(associatedMember: MemberAnnotation?) {
    self.associatedMember = associatedMember
    super.init()
  }
}

extension TeamMapViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    guard CLLocationManager.locationServicesEnabled() else {
      print("Location services disabled")
      return
    }
    
    switch CLLocationManager.authorizationStatus() {
    case .NotDetermined:
      print("Not determined")
      self.locationManager.requestWhenInUseAuthorization()
      
    case .Restricted:
      self.mapView.showsUserLocation = false
      
      let alert = UIAlertController(title: "Location access restricted", message: "Coordinate is not authorised use location services", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
      
    case .Denied:
      self.mapView.showsUserLocation = false
      
    case .AuthorizedWhenInUse, .AuthorizedAlways:
      self.mapView.showsUserLocation = true
    }
  }
}
