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
  
  var locationsRef: Firebase? {
    willSet {
      locationsRef?.observeSingleEventOfType(.Value, withBlock: { (locationsSnap) in
        while let x = locationsSnap.children.nextObject() as? FDataSnapshot {
          x.ref.removeAllObservers()
        }
      })
    }
  }
  
  
  @IBAction func temporaryWaypointTapped(sender: UITapGestureRecognizer) {
    if let annotation = (sender.view as? MKAnnotationView)?.annotation as? Annotation {
      let member = annotation.member.username
      
      let dictionary = ["lat" : self.mapView.centerCoordinate.latitude, "lon" : self.mapView.centerCoordinate.longitude]
      self.waypointRef!.childByAppendingPath("\(member)/0").setValue(dictionary)
      
      self.polylineForTemporaryWaypoint = nil
    }
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
      if let annotation = annotation as? MemberWaypointAnnotation {
        if annotation.member.username == username {
          self.mapView.removeAnnotation(annotation)
        }
      }
      if let annotation = annotation as? CurrentMemberWaypointAnnotation where username == self.team!.currentMember.username {
//        if annotation.associatedMember?.title == username {
          self.mapView.removeAnnotation(annotation)
//        }
      }
    }
    
    if username == self.team!.currentMember.username {
      var annotation = CurrentMemberWaypointAnnotation()
      
      annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      annotation.title = "You need to go here"
      self.mapView.addAnnotation(annotation)
    } else {
      let index = self.mapView.annotations.indexOf({ (annotation: MKAnnotation) -> Bool in
        guard let annotation = annotation as? Annotation else {
          return false
        }
        return annotation.member.username == username
      })
      
      let userAnnotation = self.mapView.annotations[index!] as! Annotation
      
      var annotation = MemberWaypointAnnotation(member: userAnnotation.member)
      annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      annotation.title = "Sending \(username) here"
      
      self.mapView.addAnnotation(annotation)
    }
  }
  
  func waypointRemoved(snap: FDataSnapshot!) {
    let username = snap.ref.parent.key
    print(snap.value)
    
    // Remove waypoint for this user if it exists already
    let waypoints: [MKAnnotation]
    // If this user is current user, remove CurrentWaypoints
    if username == self.team!.currentMember.username {
      waypoints = self.mapView.annotations.filter({ (annotation: MKAnnotation) -> Bool in
        return annotation is CurrentMemberWaypointAnnotation
      })
    } else {
      waypoints = self.mapView.annotations.filter({ (annotation: MKAnnotation) -> Bool in
        if let annotation = annotation as? MemberWaypointAnnotation {
          return annotation.member.username == username
        }
        return false
      })
    }
    
    self.mapView.removeAnnotations(waypoints)
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
      FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)/name").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) in
        let fullname = userSnap.value as? String
        if fullname == nil {
          print("TeamMapVC failed to get full name for user \(username)")
        }
        
        self.fullnames[username] = fullname
        
        self.locationsRef!.childByAppendingPath(username).queryLimitedToLast(1).observeEventType(.ChildAdded, withBlock: self.updateMemberLocation)
      })
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
    let waypoints = self.mapView.annotations.filter { (annotation: MKAnnotation) -> Bool in
      if let annotation = annotation as? MemberWaypointAnnotation {
        return annotation.member.username == username
      }
      return false
    }
    self.mapView.removeAnnotations(waypoints)
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
    let index = self.mapView.annotations.indexOf { (annotation: MKAnnotation) -> Bool in
      if let annotation = annotation as? MemberLocationAnnotation where annotation.member.username == username {
        return true
      }
      
      return false
    }
    
    if let index = index {
      let userAnnotation = self.mapView.annotations[index] as! MemberLocationAnnotation
      userAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      // remove annotation & re-add??
    } else {
      let member = Team.Member(username: username)
      member.name = self.fullnames[username]
      let annotation = MemberLocationAnnotation(member: member)
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
      let memberAnnotation = self.mapView.annotations[index] as! Annotation
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
    case let annotation as MemberLocationAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("MemberPinAnnotation")
      if annotationView == nil {
        annotationView = MemberAnnotationView(annotation: annotation, reuseIdentifier: "MemberPinAnnotation")
        
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TeamMapViewController.longPressed(_:)))
        longPress.delegate = self
        longPress.delaysTouchesBegan = false
        longPress.cancelsTouchesInView = true
        annotationView.addGestureRecognizer(longPress)
      } else {
        annotationView.annotation = annotation
      }
      
      (annotationView as! MemberAnnotationView).member = annotation.member
      
      annotationView.canShowCallout = true
      
    case let annotation as MemberWaypointAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("WaypointPinAnnotation")
      if annotationView == nil {
//        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "WaypointPinAnnotation")
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "WaypointPinAnnotation")
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TeamMapViewController.longPressed(_:)))
//        longPress.delegate = self
//        longPress.delaysTouchesBegan = false
//        longPress.cancelsTouchesInView = true
//        annotationView.addGestureRecognizer(longPress)
        
        let crossButton = UIButton(type: .Custom)
        let cross = UIImage(named: "cross")
        crossButton.setImage(cross, forState: .Normal)
        crossButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        annotationView.rightCalloutAccessoryView = crossButton
      }
      let color = UIColor(red: 0.118, green: 0.247, blue: 0.121, alpha: 1.000)
      annotationView.image = CoordinateStyleKit.imageOfRoundedContact(backgroundColor: color, textColor: color.contrastingTextColor(), initialsText: annotation.member.name!.initials().uppercaseString, showIndex: true, indexText: "1")
      
//      annotationView.leftCalloutAccessoryView = nil
      
//      annotationView!.draggable = true
      annotationView.canShowCallout = true
    
    case is CurrentMemberWaypointAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CurrentWaypointPinAnnotation")
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CurrentWaypointPinAnnotation")
        
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
      (annotationView! as! MKPinAnnotationView).pinTintColor = UIColor.blueColor()
      
//      let tick = UIButton(type: .ContactAdd)
//      annotationView.leftCalloutAccessoryView = tick
      
//      annotationView!.draggable = true
      annotationView.canShowCallout = true
    
    case let annotation as TempWaypointAnnotation:
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("TempWaypointPinAnnotation")
      if annotationView == nil {
        annotationView = MemberTemporaryWaypointAnnotationView(annotation: annotation, reuseIdentifier: "TempWaypointPinAnnotation")
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TeamMapViewController.longPressed(_:)))
//        longPress.delegate = self
//        longPress.delaysTouchesBegan = false
//        longPress.cancelsTouchesInView = false
//        annotationView.addGestureRecognizer(longPress)
        
//        let crossButton = UIButton(type: .Custom)
//        let cross = UIImage(named: "cross")
//        crossButton.setImage(cross, forState: .Normal)
//        crossButton.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
//        annotationView.rightCalloutAccessoryView = crossButton
      }
//      annotationView!.centerOffset = CGPointMake(10, -50)
//      (annotationView! as! MKPinAnnotationView).pinTintColor = UIColor.grayColor()
      
      //      let tick = UIButton(type: .ContactAdd)
      //      annotationView.leftCalloutAccessoryView = tick
      
      let member = Team.Member(username: annotation.username)
      member.name = self.fullnames[annotation.username]
      (annotationView as! MemberAnnotationView).member = member
      
      annotationView!.draggable = true
      annotationView.canShowCallout = true
      
    default:
      fatalError("unknown annotation type")
    }
    
    return annotationView
  }
  
  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    self.currentlyPreviewingMember = nil
  }
  
  
  func longPressed(sender: UILongPressGestureRecognizer) {
    if sender.state == .Began {
      let annotationView = sender.view as! MemberAnnotationView
      annotationView.setSelected(false, animated: false)
      
      var point = sender.locationInView(self.mapView)
      point.y -= 36
      let coordinate = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
      
      let memberAnnotation = annotationView.annotation as! MemberLocationAnnotation
      self.longPressedForMemberAnnotation(memberAnnotation, atCoordinate: coordinate)
      
      self.mapView.deselectAnnotation(annotationView.annotation, animated: true)
    }
    if sender.state == .Changed {
      let touchPoint = sender.locationInView(self.mapView)
      self.mapView.annotations.forEach({ if let temp = $0 as? TempWaypointAnnotation {
        temp.coordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)

        let annotationView = self.mapView.viewForAnnotation(temp) as! MemberTemporaryWaypointAnnotationView
        annotationView.centerOffset = CGPoint(x: 0, y: -36)
        annotationView.setSelected(false, animated: false)
        }
      })
    }
    if sender.state == .Ended {
      var tempAnnotation: TempWaypointAnnotation!
      self.mapView.annotations.forEach({ if let x = $0 as? TempWaypointAnnotation {
        tempAnnotation = x
        }
      })
      
      var touchPoint = sender.locationInView(self.mapView)
      touchPoint.y += -36
      tempAnnotation.coordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
      
      let annotationView = self.mapView.viewForAnnotation(tempAnnotation) as! MemberWaypointAnnotationView
      annotationView.centerOffset = CGPointZero
//      annotationView.setDragState(.Ending, animated: true)
      annotationView.setSelected(true, animated: true)
    }
  }
  
  private func longPressedForMemberAnnotation(memberAnnotation: Annotation, atCoordinate coordinate: CLLocationCoordinate2D? = nil) {
    // Remove other waypoint(s) for this member
    let tempWaypoints = self.mapView.annotations.filter { (annotation: MKAnnotation) -> Bool in
      if let annotation = annotation as? TempWaypointAnnotation {
//        return annotation.member.username == memberAnnotation.member.username
        return true
      }
      return false
    }
    self.mapView.removeAnnotations(tempWaypoints)
    
    self.mapView.annotations.forEach { (annotation: MKAnnotation) in
      if let annotation = annotation as? MemberWaypointAnnotation {
        if annotation.member.username == memberAnnotation.member.username {
          self.mapView.viewForAnnotation(annotation)?.alpha = 0.7
        }
      }
    }
    
    var coords = [memberAnnotation.coordinate, coordinate ?? self.mapView.centerCoordinate]
    self.polylineForTemporaryWaypoint = MKPolyline(coordinates: &coords, count: 2)
    
//    self.centerPin.alpha = 0.9
    let tempWaypoint = TempWaypointAnnotation(username:memberAnnotation.title!)
    tempWaypoint.coordinate = coordinate ?? self.mapView.centerCoordinate
    tempWaypoint.title = "Send /\(memberAnnotation.title!) here"
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
    if let annotation = view.annotation as? MemberWaypointAnnotation {
      username = annotation.member.username
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
    case let annotation as MemberWaypointAnnotation:
      print("Waypoint annotation dragged")

//    case let annotation as TempWaypointAnnotation:
//      if newState == .None && oldState == .Ending {
//        // Shift annotation coordinate to where offset pin was pointing to
//        var point = self.mapView.convertCoordinate(annotation.coordinate, toPointToView: self.mapView)
//        point.y -= (view as! MemberWaypointAnnotationView).yOffset!
//        annotation.coordinate = self.mapView.convertPoint(point, toCoordinateFromView: self.mapView)
//      }
      
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
  let username: String
  
  init(username: String) {
    self.username = username
    super.init()
  }
}
class CurrentMemberWaypointAnnotation: MKPointAnnotation {
}
class Annotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
  var title: String?
  
  let member: Team.Member
  
  init(member: Team.Member) {
    self.member = member
  }
}
class MemberLocationAnnotation: Annotation {
}
class MemberWaypointAnnotation: Annotation {
  let sender: Team.Member! = nil
  
//  init(member: Team.Member, sender: Team.Member) {
//    self.sender = sender
//    super.init(member: member)
//  }
}
//class WaypointAnnotation: MKPointAnnotation {
//  let associatedMember: MemberAnnotation?
//  var isTemporary = false
//  
//  convenience override init() {
//    self.init(associatedMember: nil)
//  }
//  init(associatedMember: MemberAnnotation?) {
//    self.associatedMember = associatedMember
//    super.init()
//  }
//}

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
