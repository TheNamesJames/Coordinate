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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if self.backgroundBlurView == nil {
      self.backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
      self.backgroundBlurView.frame = self.bounds
      self.insertSubview(self.backgroundBlurView, atIndex: 0)
    }
    
    var rowsToShow = self.numberOfRowsInSection(0)
    if rowsToShow > 3 {
      rowsToShow = 3
    }
    let inset = self.frame.height - CGFloat(rowsToShow) * self.rowHeight
    self.contentInset = UIEdgeInsets(top: inset, left: 0.0, bottom: 0.0, right: 0.0)
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
