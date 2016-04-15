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
//        self.centerPin.hidden = false
      } else {
//        self.centerPin.hidden = true
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
  
  var currentMember: Team.Member!
  var team: Team? {
    didSet {
      if let team = self.team {
        self.teamRef = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/teams/\(team.id)/members")
        self.waypointRef = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/waypoints/\(team.id)/")
        self.locationsRef = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/locations/\(team.id)/")
        
        var handles: (added: FirebaseHandle, changed: FirebaseHandle, removed: FirebaseHandle)
        handles.added = waypointRef!.childByAppendingPath(team.currentMember.username).observeEventType(.ChildAdded, withBlock: waypointAdded)
        handles.changed = waypointRef!.childByAppendingPath(team.currentMember.username).observeEventType(.ChildChanged, withBlock: waypointAdded)
        handles.removed = waypointRef!.childByAppendingPath(team.currentMember.username).observeEventType(.ChildRemoved, withBlock: waypointRemoved)
        self.waypointHandles[team.currentMember.username] = handles
      } else {
        self.teamRef = nil
        self.waypointRef = nil
      }
    }
  }
  var fullnames = [String : String]() // Stores full names for each username
  
  private var locationsHandles = [String : [FirebaseHandle]]()
  var locationsRef: Firebase? {
    willSet {
      for (username, _) in self.locationsHandles {
        locationsRef?.childByAppendingPath(username).removeAllObservers()
      }
      locationsHandles = [:] // Clear out
    }
  }
  
  
  @IBAction func temporaryWaypointTapped(sender: UITapGestureRecognizer) {
//    let waypoint = WaypointAnnotation(associatedMember: self.settingWaypointForMemberAnnotation)
//    waypoint.coordinate = self.mapView.centerCoordinate
    let member = self.settingWaypointForMemberAnnotation!.title!
//    waypoint.title = "Sending \(member) here"
//    self.mapView.addAnnotation(waypoint)
    
    let dictionary = ["lat" : self.mapView.centerCoordinate.latitude, "lon" : self.mapView.centerCoordinate.longitude]
    self.waypointRef!.childByAppendingPath("\(member)/0").setValue(dictionary)
    
    self.polylineForTemporaryWaypoint = nil
    self.settingWaypointForMemberAnnotation = nil
  }
  
  private var waypointHandles = [String : (added: FirebaseHandle, changed: FirebaseHandle, removed: FirebaseHandle)]()
  var waypointRef: Firebase? {
    willSet {
      // If being reset, then must be viewing a different team. Remove all waypoint handlers
      for (_, handles) in self.waypointHandles {
        waypointRef?.removeObserverWithHandle(handles.added)
        waypointRef?.removeObserverWithHandle(handles.changed)
        waypointRef?.removeObserverWithHandle(handles.removed)
      }
      self.waypointHandles = [:] // Clear out
    }
  }
  
  func waypointAdded(snap: FDataSnapshot!) {
    let username = snap.ref.parent.key
    guard let coordinateDictionary = snap.value as? NSDictionary else {
      return
    }
//    let coordinateDictionary = snap.value as! NSDictionary
    let lat = coordinateDictionary["lat"] as! Double
    let lon = coordinateDictionary["lon"] as! Double
    
    
    // Remove waypoint for this user if it exists already
    for annotation in self.mapView.annotations {
      if let annotation = annotation as? WaypointAnnotation {
        if annotation.associatedMember?.title == username {
          self.mapView.removeAnnotation(annotation)
        }
      }
      if let annotation = annotation as? CurrentMemberWaypointAnnotation where username == self.team!.currentMember.username {
//        if annotation.associatedMember?.title == username {
          self.mapView.removeAnnotation(annotation)
//        }
      }
    }
    
    if let index = self.mapView.annotations.indexOf({ $0.title! == username }) {
      let userAnnotation = self.mapView.annotations[index] as! MemberAnnotation

      var annotation = WaypointAnnotation(associatedMember: userAnnotation)
      annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      annotation.title = "Sending \(username) here"
      
      self.mapView.addAnnotation(annotation)
    } else if username == self.team!.currentMember.username {
      var annotation = CurrentMemberWaypointAnnotation()
      
      annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      annotation.title = "You need to go here"
      self.mapView.addAnnotation(annotation)
    }
  }
  
  func waypointRemoved(snap: FDataSnapshot!) {
    let username = snap.ref.parent.key
    
    // Remove waypoint for this user if it exists already
    for annotation in self.mapView.annotations {
      if let annotation = annotation as? WaypointAnnotation {
        if annotation.associatedMember?.title == username {
          self.mapView.removeAnnotation(annotation)
        }
      }
      if let annotation = annotation as? CurrentMemberWaypointAnnotation where username == self.team!.currentMember.username {
        self.mapView.removeAnnotation(annotation)
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
  
  func memberAdded(snap: FDataSnapshot!) {
    let username = snap.key
    
    // If member is not currentMember, add pin annotation
    if username != self.team!.currentMember.username {
      let handle = self.locationsRef!.childByAppendingPath(username).queryLimitedToLast(1).observeEventType(.ChildAdded, withBlock: updateMemberLocation)
      
      FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)/name").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) in
        let fullname = userSnap.value as? String
        if fullname == nil {
          print("TeamMapVC failed to get full name for user \(username)")
        }
        
        self.fullnames[username] = fullname
      })
      
      if self.locationsHandles[username] != nil {
        self.locationsHandles[username]!.append(handle)
      } else {
        self.locationsHandles[username] = [handle]
      }
    }
    
  }
  
  func memberRemoved(snap: FDataSnapshot!) {
    let username = snap.key
    
    self.fullnames.removeValueForKey(username)
    
    self.waypointRef!.childByAppendingPath(username).removeAllObservers()
    self.locationsRef!.childByAppendingPath(username).removeAllObservers()
    
    // Remove location pin
    let index = self.mapView.annotations.indexOf({ $0.title! == username })
    if let index = index {
      let annotation = self.mapView.annotations[index]
      self.mapView.removeAnnotation(annotation)
    }
    
    // Remove waypoint pin
    for annotation in self.mapView.annotations {
      if let annotation = annotation as? WaypointAnnotation {
        if annotation.associatedMember?.title == username {
          self.mapView.removeAnnotation(annotation)
        }
      }
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
    
    var handles: (added: FirebaseHandle, changed: FirebaseHandle, removed: FirebaseHandle)
    handles.added = waypointRef!.childByAppendingPath(username).observeEventType(.ChildAdded, withBlock: waypointAdded)
    handles.changed = waypointRef!.childByAppendingPath(username).observeEventType(.ChildChanged, withBlock: waypointAdded)
    handles.removed = waypointRef!.childByAppendingPath(username).observeEventType(.ChildRemoved, withBlock: waypointRemoved)
    self.waypointHandles[username] = handles
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
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    
//    self.centerPin.alpha = 0
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
    guard CLLocationManager.locationServicesEnabled() else {
      let alert = UIAlertController(title: "Location services disabled", message: "We need location services enabled to be able to show your location", preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
      self.navigationController!.presentViewController(alert, animated: true, completion: nil)
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
      self.navigationController!.presentViewController(alert, animated: true, completion: nil)
    }
    
  }

  private var currentlyPreviewingMember: Team.Member?
  
  func previewMember(member: Team.Member?) {
    self.currentlyPreviewingMember = member
    
    guard let member = member else {
      return
    }
    
    if let index = self.mapView.annotations.indexOf({ $0.title! == member.username }) {
      
      var region = self.mapView.region
      region.span = MKCoordinateSpanMake(0.005, 0.005)
      region.center = self.mapView.annotations[index].coordinate
      
      
      MKMapView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.mapView.setRegion(region, animated: true)
        }, completion: nil)
    } else {
      UIAlertController.showAlertWithTitle("No location updates", message: "/\(member.username) has not posted any location updates yet", onViewController: self)
    }
  }

  func memberIconLongPressed(member: Team.Member) {
    if let index = self.mapView.annotations.indexOf({ $0.title! == member.username}) {
      let memberAnnotation = self.mapView.annotations[index] as! MemberAnnotation
      self.longPressedForMemberAnnotation(memberAnnotation)
    }
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
        annotationView = MemberAnnotationView(annotation: annotation, reuseIdentifier: "MemberPinAnnotation")
//        annotationView.centerOffset = CGPointMake(10, -20)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TeamMapViewController.longPressed(_:)))
        longPress.delegate = self
        longPress.delaysTouchesBegan = false
        longPress.cancelsTouchesInView = false
        annotationView.addGestureRecognizer(longPress)
      } else {
        annotationView.annotation = annotation
      }
      
      let initials = self.fullnames[annotation.title!]?.initials().uppercaseString ?? "/\(annotation.title!)"
      let imageView = (annotationView as! MemberAnnotationView).imageView
      imageView.image = UIImage.imageWithCenteredText(initials, withSize: imageView.bounds.size)
      
//      annotationView.draggable = true
      
      annotationView.canShowCallout = true
      
    case is WaypointAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("WaypointPinAnnotation")
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "WaypointPinAnnotation")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TeamMapViewController.longPressed(_:)))
        longPress.delegate = self
        longPress.delaysTouchesBegan = false
        longPress.cancelsTouchesInView = false
        annotationView.addGestureRecognizer(longPress)
        
        let crossButton = UIButton(type: .Custom)
        let cross = UIImage(named: "cross")
        crossButton.setImage(cross, forState: .Normal)
        crossButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        annotationView.rightCalloutAccessoryView = crossButton
      }
//      annotationView!.centerOffset = CGPointMake(10, -50)
      (annotationView! as! MKPinAnnotationView).pinTintColor = UIColor.greenColor()
      
//      annotationView.leftCalloutAccessoryView = nil
      
//      annotationView!.draggable = true
      annotationView.canShowCallout = true
    
    case is CurrentMemberWaypointAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("WaypointPinAnnotation")
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "WaypointPinAnnotation")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TeamMapViewController.longPressed(_:)))
        longPress.delegate = self
        longPress.delaysTouchesBegan = false
        longPress.cancelsTouchesInView = false
        annotationView.addGestureRecognizer(longPress)
        
        let crossButton = UIButton(type: .Custom)
        let cross = UIImage(named: "cross")
        crossButton.setImage(cross, forState: .Normal)
        crossButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        annotationView.rightCalloutAccessoryView = crossButton
      }
//      annotationView!.centerOffset = CGPointMake(10, -50)
      (annotationView! as! MKPinAnnotationView).pinTintColor = UIColor.blueColor()
      
//      let tick = UIButton(type: .ContactAdd)
//      annotationView.leftCalloutAccessoryView = tick
      
//      annotationView!.draggable = true
      annotationView.canShowCallout = true
    
    case is TempWaypointAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("TempWaypointPinAnnotation")
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "TempWaypointPinAnnotation")
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TeamMapViewController.longPressed(_:)))
//        longPress.delegate = self
//        longPress.delaysTouchesBegan = false
//        longPress.cancelsTouchesInView = false
//        annotationView.addGestureRecognizer(longPress)
        
        let crossButton = UIButton(type: .Custom)
        let cross = UIImage(named: "cross")
        crossButton.setImage(cross, forState: .Normal)
        crossButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        annotationView.rightCalloutAccessoryView = crossButton
      }
//      annotationView!.centerOffset = CGPointMake(10, -50)
      (annotationView! as! MKPinAnnotationView).pinTintColor = UIColor.grayColor()
      
      //      let tick = UIButton(type: .ContactAdd)
      //      annotationView.leftCalloutAccessoryView = tick
      
      annotationView!.draggable = true
      annotationView.canShowCallout = true
      
    default:
      fatalError("unknown annotation type")
    }
    
    return annotationView
  }
  
  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    if let _ = self.settingWaypointForMemberAnnotation {
//      self.centerPin.alpha = 0.7
    }
    
    self.currentlyPreviewingMember = nil
  }
  
  func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if let _ = self.settingWaypointForMemberAnnotation {
//      self.centerPin.alpha = 0.9
      
      var coords = [self.settingWaypointForMemberAnnotation!.coordinate, self.mapView.centerCoordinate]
      self.polylineForTemporaryWaypoint = MKPolyline(coordinates: &coords, count: 2)
      // TODO: (re)draw dotted line from member to here
    }
  }
  
  func longPressed(sender: UILongPressGestureRecognizer) {
    if sender.state == .Began {
      let pinAnnotation = sender.view as! MemberAnnotationView
      pinAnnotation.selected = false
      
      self.mapView.removeAnnotations(self.mapView.annotations.filter({ $0 is TempWaypointAnnotation }))
      
      if let memberAnnotation = pinAnnotation.annotation as? MemberAnnotation {
        self.longPressedForMemberAnnotation(memberAnnotation)
      } else {
        let memberWaypoint = pinAnnotation.annotation as! WaypointAnnotation
        let memberAnnotation = memberWaypoint.associatedMember!
        self.longPressedForMemberAnnotation(memberAnnotation)
      }
      
      
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
      
      var tempAnnotation: TempWaypointAnnotation!
      self.mapView.annotations.forEach({ if let x = $0 as? TempWaypointAnnotation {
        tempAnnotation = x
        }
      })
      
      let touchPoint = sender.locationInView(self.mapView)
      tempAnnotation.coordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
      
      // TODO: Fix up pan on dragging to edge hit points?
//      let delta = self.mapView.region.span.latitudeDelta / 50
//      let centerDiff = isPoint(touchPoint, atEdgeOfViewFrame: self.mapView.frame)
//      
//      MKMapView.animateWithDuration(0.1, animations: {
//        if let magnitude = centerDiff.latitude?.rawValue {
//          self.mapView.centerCoordinate.latitude += magnitude * delta
//          tempAnnotation.coordinate.latitude += magnitude * delta
//        }
//        if let magnitude = centerDiff.longitude?.rawValue {
//          self.mapView.centerCoordinate.longitude += magnitude * delta
//          tempAnnotation.coordinate.longitude += magnitude * delta
//        }
//      })
    }
  }
//  private enum Magnitude : Double {
//    case Postive  = 1
//    case None     = 0
//    case Negative = -1
//  }
//  private func isPoint(p: CGPoint, atEdgeOfViewFrame frame: CGRect) -> (latitude: Magnitude?, longitude: Magnitude?) {
//    let dist: CGFloat = 48
//    
//    guard !frame.insetBy(dx: dist, dy: dist).contains(p) else {
//      return (nil, nil)
//    }
//    
//    let left = frame.divide(dist, fromEdge: .MinXEdge).slice
//    let right = frame.divide(dist, fromEdge: .MaxXEdge).slice
//    
//    let top = frame.divide(dist, fromEdge: .MinYEdge).slice
//    let bottom = frame.divide(dist, fromEdge: .MaxYEdge).slice
//    
//    var result: (latitude: Magnitude?, longitude: Magnitude?)
//    if left.contains(p) {
//      result.longitude = .Negative
//    } else if right.contains(p) {
//      result.longitude = .Postive
//    }
//    
//    if top.contains(p) {
//      result.latitude = .Postive
//    } else if bottom.contains(p) {
//      result.latitude = .Negative
//    }
//    
//    return result
//  }
  
  private func longPressedForMemberAnnotation(annotation: MemberAnnotation) {
    self.settingWaypointForMemberAnnotation = annotation
    
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
    
//    self.centerPin.alpha = 0.9
    let tempWaypoint = TempWaypointAnnotation()
    tempWaypoint.coordinate = annotation.coordinate
    tempWaypoint.title = "Send /\(annotation.title!) here"
    self.mapView.addAnnotation(tempWaypoint)
//    self.mapView.selectAnnotation(tempWaypoint, animated: true)
  }
  
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = UIColor.blueColor()
      polylineRenderer.lineWidth = 5
      return polylineRenderer
//    }
  }
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let username: String!
    if let annotation = view.annotation as? WaypointAnnotation {
      username = annotation.associatedMember!.title
    } else if view.annotation is CurrentMemberWaypointAnnotation {
      username = self.team!.currentMember.username
    } else {
      print("Accessory tapped but unable to get corresponding member..")
      return
    }
    
    self.waypointRef!.childByAppendingPath(username).removeValue()
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
        
//        (view as! MKPinAnnotationView).pinTintColor = UIColor.blueColor()
        view.canShowCallout = true
      }
      
    case let annotation as WaypointAnnotation:
      print("Waypoint annotation dragged")
      
    default:
      print("dragging unexpected annotation: \(view.annotation)")
    }
  }
  
  func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
    let newCenter = userLocation.coordinate
    var dataDictionary: [String:AnyObject] = [:]
    // TODO: timestamp
    dataDictionary["lat"] = newCenter.latitude
    dataDictionary["lon"] = newCenter.longitude
    
    if let username = self.team?.currentMember.username {
      self.locationsRef?.childByAppendingPath(username).childByAutoId().setValue(dataDictionary)
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

class TempWaypointAnnotation: MKPointAnnotation {
}
class CurrentMemberWaypointAnnotation: MKPointAnnotation {
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
      self.navigationController!.presentViewController(alert, animated: true, completion: nil)
      
    case .Denied:
      self.mapView.showsUserLocation = false
      
    case .AuthorizedWhenInUse, .AuthorizedAlways:
      self.mapView.showsUserLocation = true
    }
  }
}
