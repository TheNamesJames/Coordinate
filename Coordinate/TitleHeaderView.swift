//
//  TitleHeaderView.swift
//  Coordinate
//
//  Created by James Wilkinson on 18/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class TitleHeaderView: UITableViewHeaderFooterView {
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // TODO: Update font/size/alignment to something snazzy
    self.textLabel?.textColor = UIColor(white: 0.9, alpha: 1.0)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
