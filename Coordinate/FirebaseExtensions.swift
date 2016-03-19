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
  let defaults = NSUserDefaults.standardUserDefaults()
  defaults.setObject(nil, forKey: kPreviouslySelectedTeamIDKey)
  
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

let kPreviouslySelectedTeamIDKey = "previouslySelectedTeamID"

private var currentMember: Team.Member? = nil
private var initialMemberships: [String] = []
/// Gets current member and an initial list of associated team ID's
/// Returns true if logged in, false otherwise
func getCurrentMemberWithCompleteBlock(block: ((uid: String, currentMember:Team.Member, teamIDs: [String]) -> Void)?) -> Bool {
  guard let uid = FIREBASE_ROOT_REF.authData?.uid else {
    currentMember = nil
    initialMemberships = []
    return false
  }
  
  if let currentMember = currentMember {
    block?(uid: uid, currentMember: currentMember, teamIDs: initialMemberships)
  } else {
    FIREBASE_ROOT_REF.childByAppendingPath("identifiers/\(uid)").observeSingleEventOfType(.Value, withBlock: { (idSnap) -> Void in
      guard let username = idSnap.value as? String else {
        return
      }
      let user = Team.Member(username: username)
      
      FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) -> Void in
        guard let userDict = userSnap.value as? [String : AnyObject] else {
          print("\(username) does not have a team branch or name")
          currentMember = user
          return
        }
        
        user.name = userDict["name"] as! String?
        if let teamsDict = userDict["teams"] as? [String : AnyObject] {
          initialMemberships = Array(teamsDict.keys)
        } else {
          initialMemberships = []
        }
        currentMember = user
        block?(uid: uid, currentMember: currentMember!, teamIDs: initialMemberships)
      })
      //        FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)/teams").observeSingleEventOfType(.Value, withBlock: { (teamsSnap) -> Void in
      //          print(teamsSnap.value)
      //        })
    })
  }
  
  return true
}