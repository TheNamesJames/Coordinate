//
//  MemberTableViewCell.swift
//  Coordinate
//
//  Created by James Wilkinson on 19/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  override var textLabel: UILabel? {
    return self.nameLabel
  }
  
  @IBOutlet weak var cellBlurView: UIVisualEffectView!
  
  @IBOutlet weak var contactImage: UIImageView!
  override var imageView: UIImageView? {
    return self.contactImage
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.imageView!.layer.cornerRadius = self.imageView!.frame.width/2
    self.imageView!.clipsToBounds = true
    self.imageView!.layer.borderWidth = 2.0
    self.imageView!.layer.borderColor = UIColor.clearColor().CGColor
    
    self.cellBlurView.effect = nil
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setContactColour(colour: UIColor) {
    self.imageView!.layer.borderColor = colour.CGColor
  }
  
}
