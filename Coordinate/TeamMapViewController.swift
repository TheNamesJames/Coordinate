//
//  TeamMapViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 23/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import MapKit
//import PubNub
import Firebase

class TeamMapViewController: UIViewController, PreviewMemberListener {
  
  @IBOutlet weak var mapView: MKMapView!
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/")
  var team: Team!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    // Show all team members last locations
    // 1: Get all team members for team ID
    ref.childByAppendingPath("teams/\(self.team.id)/members").observeEventType(.ChildAdded) { (memberSnap: FDataSnapshot!) -> Void in
      let username = memberSnap.key
      
      // 2: As location updates arrive for this username
      self.ref.childByAppendingPath("locations/\(self.team.id)/\(username)").queryLimitedToLast(1).observeEventType(.ChildAdded, withBlock: { (lastLocationSnap: FDataSnapshot!) -> Void in
        let dictionary = lastLocationSnap.value as! [String:Double]
        
        guard let lat = dictionary["lat"],
          let lon = dictionary["lon"] else {
          print("WARNING: Latest location update \(lastLocationSnap.key) has no lat value")
          return
        }
        
        // 3: Add/update annotation for that user
        let index = self.mapView.annotations.indexOf({ $0.title! == username })
        if let index = index {
          let userAnnotation = self.mapView.annotations[index] as! MKPointAnnotation
          userAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
          // remove annotation & re-add??
        } else {
          let annotation = MKPointAnnotation()
          annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
          annotation.title = username
//          annotation.subtitle = first & last?? OR time??
          self.mapView.addAnnotation(annotation)
        }
        
        if self.currentlyPreviewingMember?.username == username {
          self.previewMember(self.currentlyPreviewingMember)
        }
      })
    }
    
    
//    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    delegate.pubnubClient?.addListener(self)
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
  
  private var prePreviewMapRect: MKMapRect? = nil
  private var currentlyPreviewingMember: Team.Member?
  
  func previewMember(member: Team.Member?) {
    self.currentlyPreviewingMember = member
    
    if let member = member {
      if prePreviewMapRect == nil {
        prePreviewMapRect = self.mapView.visibleMapRect
      }
      
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
    } else {
      if self.prePreviewMapRect != nil {
        mapView.setVisibleMapRect(self.prePreviewMapRect!, animated:true)
        prePreviewMapRect = nil
      }
    }
  }
}

extension TeamMapViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation === mapView.userLocation {
      return nil
    }
    
    var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("MemberPinAnnotation")
    if annotationView == nil {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MemberPinAnnotation")
      annotationView!.centerOffset = CGPointMake(10, -20)
    }
    
    annotationView!.annotation = annotation
    
    return annotationView
  }
}

//extension TeamMapViewController: PNObjectEventListener {
//  func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
//    print(message.data.message)
//    let x = message.data.message as! NSDictionary
//    let lat = x.valueForKey("latitude") as! Double
//    let lon = x.valueForKey("longitude") as! Double
//    
//    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//    
//    for annotation in self.mapView.annotations {
//      if let annotation = annotation as? MKPointAnnotation,
//        title = annotation.title where title == "John" {
//          UIView.animateWithDuration(0.1, animations: { () -> Void in
//            annotation.coordinate = coordinate
//          })
//      }
//    }
//    
//  }
//}
