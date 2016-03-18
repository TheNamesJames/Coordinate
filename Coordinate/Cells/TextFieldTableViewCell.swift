//
//  TextFieldTableViewCell.swift
//  Coordinate
//
//  Created by James Wilkinson on 17/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

  class ListItem {
    var text: String
    
    convenience init() {
      self.init(text: "")
    }
    init(text: String) {
      self.text = text
    }
  }
  
  var listItem: ListItem! {
    didSet {
      self.textField.text = self.listItem.text
    }
  }
  
  @IBOutlet var textField: UITextField! {
    didSet {
      self.textField.delegate = self
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    self.backgroundColor = UIColor.clearColor()
    self.selectionStyle = .None
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
    if selected {
      self.textField.userInteractionEnabled = true
      self.textField.becomeFirstResponder()
    } else {
      self.textField.userInteractionEnabled = false
      self.textField.resignFirstResponder()
    }
  }

//  override func becomeFirstResponder() -> Bool {
//    self.textField.userInteractionEnabled = true
//    return textField.becomeFirstResponder()
//  }
}

extension TextFieldTableViewCell: UITextFieldDelegate {
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    let text = (textField.text as NSString?)?.stringByReplacingCharactersInRange(range, withString: string)
    
    self.listItem.text = text ?? ""
    
    return true
  }
}
