//
//  TransparentTableView.swift
//  Coordinate
//
//  Created by James Wilkinson on 23/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class TransparentTableView: UITableView {
  
  var backgroundBlurView: UIVisualEffectView!
  
  override var contentSize: CGSize {
    didSet {
      self.backgroundBlurView?.frame = CGRect(origin: CGPointZero, size: self.contentSize)
    }
  }
  
  override var frame: CGRect {
    didSet {
      let inset = frame.height - CGFloat(1) * self.rowHeight
      // FIXME: Should auto-scroll to inset initially (i.e. on init?)
      self.contentInset = UIEdgeInsets(top: inset, left: 0.0, bottom: 0.0, right: 0.0)
      self.contentOffset = CGPoint(x: 0.0, y: -inset)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if self.backgroundBlurView == nil {
      self.backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
      
      self.backgroundBlurView.frame = CGRect(origin: CGPointZero, size: self.contentSize)
      self.insertSubview(self.backgroundBlurView, atIndex: 0)
    }
  }
  
  // Ignore touch if not inside cell or blur background
  override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
    if let _ = self.indexPathForRowAtPoint(point) {
      return super.hitTest(point, withEvent: event)
    }
    if self.backgroundBlurView.pointInside(point, withEvent: event) != false {
      return super.hitTest(point, withEvent: event)
    }
    
    return nil
  }
}
