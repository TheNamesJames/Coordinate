//
//  FirebaseExtensions.swift
//  Coordinate
//
//  Created by James Wilkinson on 18/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import Foundation
import Firebase

let FIREBASE_ROOT_REF = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/")

func unauthAndDismissToLoginFrom(viewcontroller: UIViewController) {
  FIREBASE_ROOT_REF.unauth()
  
  let nav = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginNavigationController") as! UINavigationController
  
//  let appDelegate = UIApplication.sharedApplication().delegate
//  appDelegate?.window!?.rootViewController = nav
//  nav.presentViewController(viewcontroller, animated: false, completion: { () -> Void in
//  })
//  nav.presentedViewController!.dismissViewControllerAnimated(true, completion: nil)

  nav.modalTransitionStyle = .CrossDissolve
  let appDelegate = UIApplication.sharedApplication().delegate
  appDelegate?.window!?.rootViewController!.presentViewController(nav, animated: true) { () -> Void in
    appDelegate?.window!?.rootViewController = nav
  }
  
  
  //  nav.pushViewController(viewcontroller, animated: false)
  //  viewcontroller.navigationItem.hidesBackButton = true
  //  let appDelegate = UIApplication.sharedApplication().delegate
  //  appDelegate?.window!?.rootViewController = nav
  //  nav.popToRootViewControllerAnimated(true)
}