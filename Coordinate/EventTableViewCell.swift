//
//  EventTableViewCell.swift
//  Coordinate
//
//  Created by James Wilkinson on 20/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
  
  @IBOutlet weak var eventImage: UIImageView!
  override var imageView: UIImageView? {
    return self.eventImage
  }
  
  @IBOutlet weak var eventLabel: UILabel!
  override var textLabel: UILabel? {
    return self.eventLabel
  }
  
  @IBOutlet var contactImages: [UIImageView]!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    
  }
  
}
