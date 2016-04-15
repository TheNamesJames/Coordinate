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
  
  var imageView: UIImageView
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    self.imageView = RoundedImageView(frame: CGRectMake(0, 0, 36, 36))
    
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    
//    imageView.image = UIImage(named: cpa.imageName);
//    imageView.layer.cornerRadius = imageView.layer.frame.size.width / 2
    customInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    self.imageView = RoundedImageView(frame: CGRectMake(0, 0, 36, 36))
    
    var frame = frame
    frame.size = CGSize(width: 36, height: 36)
    super.init(frame: frame)
    
    customInit()
  }
  
  private func customInit() {
    self.imageView.layer.masksToBounds = true
    self.imageView.userInteractionEnabled = false
    self.addSubview(imageView)
  }
  
  /*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func drawRect(rect: CGRect) {
   // Drawing code
   }
   */
  
}
