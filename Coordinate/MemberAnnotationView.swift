//
//  MemberAnnotationView.swift
//  Coordinate
//
//  Created by James Wilkinson on 15/04/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import MapKit

class MemberAnnotationView: MKAnnotationView {
  
  var mainColor: UIColor!
  var member: Team.Member! {
    didSet {
      let initials = member.name!.initials().uppercaseString
      self.image = CoordinateStyleKit.imageOfRoundedContact(backgroundColor: self.mainColor, textColor: self.mainColor.contrastingTextColor(), initialsText: initials, showIndex: false, indexText: "")
    }
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    self.mainColor = UIColor(red: 0.118, green: 0.247, blue: 0.121, alpha: 1.000)
    
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
//    self.imageView = RoundedImageView(frame: CGRectMake(0, 0, 36, 36))
//    
//    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//    
////    imageView.image = UIImage(named: cpa.imageName);
////    imageView.layer.cornerRadius = imageView.layer.frame.size.width / 2
//    customInit()
//  }
//  
  override init(frame: CGRect) {
    self.mainColor = UIColor(red: 0.118, green: 0.247, blue: 0.121, alpha: 1.000)
    super.init(frame: frame)
  }
  
  override func setDragState(newDragState: MKAnnotationViewDragState, animated: Bool) {
    self.dragState = newDragState
    var newCenter = self.center
    switch newDragState {
    case .Starting:
      newCenter.y -= self.yOffset!
      UIView.animateWithDuration(0.2, animations: {
        self.center = newCenter
        }, completion: { (_) in
          self.dragState = .Dragging
      })
      
    case .Ending:
      fallthrough
    case .Canceling:
      newCenter.y += self.yOffset!
      UIView.animateWithDuration(0.2, animations: {
        self.center = newCenter
        }, completion: { (_) in
          self.dragState = .None
      })
      
    default:
      break
    }
    
  }
  
  override var dragState: MKAnnotationViewDragState {
    didSet {
      if dragState == .None {
        self.yOffset = nil
      }
    }
  }
  
  private(set) var yOffset: CGFloat? {
    didSet {
      if let v = self.yOffset {
        self.yOffset = v + 12 // offset + finger size
      }
    }
  }
  
  override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
    if self.dragState == .None {
      self.yOffset = self.bounds.height - point.y
    }
    
    return super.hitTest(point, withEvent: event)
  }
}

class MemberWaypointAnnotationView: MemberAnnotationView {
  
  override var member: Team.Member! {
    didSet {
      let initials = member.name!.initials().uppercaseString
      self.image = CoordinateStyleKit.imageOfRoundedContact(backgroundColor: self.mainColor, textColor: self.mainColor.contrastingTextColor(), initialsText: initials, showIndex: true, indexText: "..")
    }
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
}

class MemberTemporaryWaypointAnnotationView: MemberWaypointAnnotationView {
  
  override var member: Team.Member! {
    didSet {
      let initials = member.name!.initials().uppercaseString
      self.image = CoordinateStyleKit.imageOfTemporaryWaypoint(backgroundColor: self.mainColor, textColor: self.mainColor.contrastingTextColor(), initialsText: initials)
    }
  }
  var yesTappedAction: (Void -> Void)?
  var cancelTappedAction: (Void -> Void)?
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    let tap = UITapGestureRecognizer(target: self, action: #selector(MemberTemporaryWaypointAnnotationView.tapped))
    self.addGestureRecognizer(tap)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  func tapped(sender: UITapGestureRecognizer) {
    if sender.state == .Ended {
      let point = sender.locationInView(self)
      let topLeft = self.bounds.divide(36, fromEdge: .MinXEdge).slice
      let topRight = self.bounds.divide(36, fromEdge: .MaxXEdge).slice
      
      if CGRectContainsPoint(topLeft, point) {
        yesTappedAction?()
      } else if CGRectContainsPoint(topRight, point) {
        cancelTappedAction?()
      }
    }
  }
}

