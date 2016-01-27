//
//  UserTrackingButton.swift
//  Coordinate
//
//  Created by James Wilkinson on 23/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import MapKit

class UserTrackingButton: UIButton {
  
  weak var mapView: MKMapView? {
    willSet {
      if let mapView = mapView {
        mapView.removeObserver(self, forKeyPath: "userTrackingMode")
      }
    }
    didSet {
      if let mapView = mapView {
        let options = NSKeyValueObservingOptions.Initial.union(NSKeyValueObservingOptions.New)
        mapView.addObserver(self, forKeyPath: "userTrackingMode", options: options, context: nil)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    let trackingMode = MKUserTrackingMode(rawValue: change!["new"] as! Int)!
    
    self.updateView(trackingMode, animated: false)
  }
  
  func pressed(sender: AnyObject?) {
    let newTrackingMode: MKUserTrackingMode
    switch self.mapView?.userTrackingMode ?? .None {
    case .None:
      newTrackingMode = .Follow
    case .Follow:
      newTrackingMode = .FollowWithHeading
    case .FollowWithHeading:
      newTrackingMode = .Follow
    }
    
    self.mapView?.setUserTrackingMode(newTrackingMode, animated: true)
    self.updateView(newTrackingMode, animated: true)
  }
  
  private func updateView(trackingMode: MKUserTrackingMode, animated: Bool) {
    let title: String
    switch trackingMode {
    case .None:
      title = "Locate"
    case .Follow:
      title = "Heading"
    case .FollowWithHeading:
      title = "w/out Heading"
    }
    
    self.setTitle(title, forState: .Normal)
  }
  
  deinit {
    if let mapView = mapView {
      mapView.removeObserver(self, forKeyPath: "userTrackingMode")
    }
  }
  
  // TODO: set button images
}
