//
//  MapViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 23/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import MapKit
import PubNub

class MapViewController: UIViewController, PreviewMemberListener {
  
  var data: [Member]!
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    var annotations: [MKAnnotation] = []
    for member in data {
      let annotation = MKPointAnnotation()
      annotation.coordinate = member.location
      annotation.title = member.name
      annotations.append(annotation)
    }
    self.mapView.addAnnotations(annotations)
    
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    delegate.pubnubClient?.addListener(self)
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
  
  func previewMember(member: Member?) {
    if let member = member {
      if prePreviewMapRect == nil {
        prePreviewMapRect = self.mapView.visibleMapRect
      }
      
      var region = self.mapView.region;
      let span = MKCoordinateSpanMake(0.005, 0.005);
      
      region.center = member.location;
      
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

extension MapViewController: MKMapViewDelegate {
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

extension MapViewController: PNObjectEventListener {
  func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
    print(message.data.message)
    let x = message.data.message as! NSDictionary
    let lat = x.valueForKey("latitude") as! Double
    let lon = x.valueForKey("longitude") as! Double
    
    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    
    for annotation in self.mapView.annotations {
      if let annotation = annotation as? MKPointAnnotation,
        title = annotation.title where title == "John" {
          UIView.animateWithDuration(0.1, animations: { () -> Void in
            annotation.coordinate = coordinate
          })
      }
    }
    
  }
}
