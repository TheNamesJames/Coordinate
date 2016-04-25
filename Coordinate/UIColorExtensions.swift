//
//  UIColorExtensions.swift
//  Coordinate
//
//  Created by James Wilkinson on 16/04/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

extension UIColor {
  
  func contrastingTextColor() -> UIColor {
    var brightness : CGFloat = 0
    
    if self.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil) {
      if brightness < 0.5 {
        return UIColor.whiteColor()
      } else {
        return UIColor.blackColor()
      }
    }
    
    return UIColor.redColor()
  }
}