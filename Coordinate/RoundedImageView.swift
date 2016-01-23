//
//  RoundedImageView.swift
//  Coordinate
//
//  Created by James Wilkinson on 23/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

// TODO: Subclass this to add 'mini' group icon (á la Dribbble)
class RoundedImageView: UIImageView {
  
  var borderColour: CGColor? {
    get {
      return self.layer.borderColor
    }
    set(newColour) {
      self.layer.borderColor = newColour
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.clipsToBounds = true
    self.layer.cornerRadius = self.bounds.width / 2
    self.layer.borderColor = nil
  }
}
