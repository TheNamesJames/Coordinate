//
//  UIAlertControllerExtension.swift
//  Coordinate
//
//  Created by James Wilkinson on 26/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit


extension UIAlertController {
  
  convenience init(alertWithTitle title: String?, message: String?) {
    self.init(title: title, message: message, preferredStyle: .Alert)
    self.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
  }
  
  class func showAlertWithTitle(title: String?, message: String?, onViewController vc: UIViewController) -> UIAlertController {
    let alert = UIAlertController(alertWithTitle: title, message: message)
    if vc is UINavigationController {
      vc.presentViewController(alert, animated: true, completion: nil)
    } else if let nav = vc.navigationController {
      nav.presentViewController(alert, animated: true, completion: nil)
    } else {
      vc.presentViewController(alert, animated: true, completion: nil)
    }
    return alert
  }
  
  
  convenience init(destructiveAlertWithTitle title: String?, message: String?, defaultTitle: String?, defaultHandler: ((UIAlertAction) -> Void)) {
    self.init(title: title, message: message, preferredStyle: .Alert)
    self.addAction(UIAlertAction(title: defaultTitle, style: .Destructive, handler: defaultHandler))
    self.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
  }
  
//  class func showAlertWithTitle(title: String?, message: String?, onViewController vc: UIViewController) -> UIAlertController {
//    let alert = UIAlertController(alertWithTitle: title, message: message)
//    vc.presentViewController(alert, animated: true, completion: nil)
//    return alert
//  }
}