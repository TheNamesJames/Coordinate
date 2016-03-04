//
//  SimulatorViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 29/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class SimulatorViewController: UIViewController {
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/")
  
  var team: Team!
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var centerPin: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func panned(sender: AnyObject) {
    
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}

extension SimulatorViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.05, animations: { () -> Void in
        self.centerPin.alpha = 0.7
      })
    } else {
      self.centerPin.alpha = 0.7
    }
  }
  
  func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.05, animations: { () -> Void in
        self.centerPin.alpha = 1
      })
    } else {
      self.centerPin.alpha = 1
    }
    
    let newCenter = mapView.region.center
    var dataDictionary: [String:AnyObject] = [:]
    // TODO: Add name/id of user
    dataDictionary["lat"] = newCenter.latitude
    dataDictionary["lon"] = newCenter.longitude
    
    ref.childByAppendingPath("locations/\(team.id)/\(team.currentMember.username)").childByAutoId().setValue(dataDictionary)
  }
}
