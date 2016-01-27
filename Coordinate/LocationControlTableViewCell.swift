//
//  LocationControlTableViewCell.swift
//  Coordinate
//
//  Created by James Wilkinson on 25/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class LocationControlTableViewCell: UITableViewCell {
  
  @IBOutlet weak var userTrackingButton: UserTrackingButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
