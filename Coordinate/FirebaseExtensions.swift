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

extension Firebase {
  func authExpired() -> Bool {
    if let authData = self.authData {
      let expires = authData.expires.doubleValue
      let now = NSDate().timeIntervalSince1970
      
      return now >= expires
    }
    return true
  }
}

class FirebaseLoginHelpers {
  class func unauthAndDismissToLoginFrom(viewcontroller: UIViewController) {
    FIREBASE_ROOT_REF.unauth()
    userDefaultsForPreviouslySelectedTeamID = nil
    
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
  
  
  /*private*/ static var currentMember: Team.Member? = nil
  /*private*/ static var initialMemberships: [String] = []
  /// Gets current member and an initial list of associated team ID's
  /// Returns true if logged in, false otherwise
  class func isLoggedInWithCompleteBlock(block: ((uid: String, currentMember:Team.Member, teamIDs: [String]) -> Void)?) -> Bool {
    guard let authData = FIREBASE_ROOT_REF.authData else {
      // Remove stored references to current member, list of memberships and previously signed in team
      currentMember = nil
      initialMemberships = []
      userDefaultsForPreviouslySelectedTeamID = nil
      return false
    }
    
    if let currentMember = currentMember {
      block?(uid: authData.uid, currentMember: currentMember, teamIDs: initialMemberships)
    } else {
      FIREBASE_ROOT_REF.childByAppendingPath("identifiers/\(authData.uid)").observeSingleEventOfType(.Value, withBlock: { (idSnap) -> Void in
        guard let username = idSnap.value as? String else {
          return
        }
        let user = Team.Member(username: username)
        
        FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) -> Void in
          guard let userDict = userSnap.value as? [String : AnyObject] else {
            print("\(username) does not have a team branch or name")
            self.currentMember = user
            return
          }
          
          user.name = userDict["name"] as! String?
          if let teamsDict = userDict["teams"] as? [String : AnyObject] {
            self.initialMemberships = Array(teamsDict.keys)
          } else {
            self.initialMemberships = []
          }
          self.currentMember = user
          block?(uid: authData.uid, currentMember: self.currentMember!, teamIDs: self.initialMemberships)
        })
        //        FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)/teams").observeSingleEventOfType(.Value, withBlock: { (teamsSnap) -> Void in
        //          print(teamsSnap.value)
        //        })
      })
    }
    
    return true
  }
  
  
  static private let kPreviouslySelectedTeamIDKey = "previouslySelectedTeamID"
  static var userDefaultsForPreviouslySelectedTeamID: String? {
    get {
      return NSUserDefaults.standardUserDefaults().stringForKey(kPreviouslySelectedTeamIDKey)
    }
    set(id) {
      NSUserDefaults.standardUserDefaults().setObject(id, forKey: kPreviouslySelectedTeamIDKey)
    }
  }
  
  struct CurrentLoggedInUserDetails {
    let uid: String
    let member: Team.Member
    let memberships: [String]
  }
  
  enum LoginHelperErrorCode {
    enum UserError {
      case EmailPasswordCombinationNotRecognised
      
      case EmailNotRecognised
      case EmailTaken
      
      case UsernameNotRecognised
      case UsernameTaken
    }
    enum FormatError {
      case IdentifiersBranch
      case UsersBranch
    }
    case User(UserError)
    case InvalidFormat
  }
  
  func login(email: String, _ password: String, completion:((error: LoginHelperErrorCode?, CurrentLoggedInUserDetails?) -> Void)) {
    FIREBASE_ROOT_REF.authUser(email, password: password) { (error, authData) in
      guard error != nil else {
        print(error)
        completion(error: .User(.EmailPasswordCombinationNotRecognised), nil)
        return
      }
      
      FIREBASE_ROOT_REF.childByAppendingPath("identifiers/\(authData.uid)").observeSingleEventOfType(.Value, withBlock: { (idSnap) in
        guard let username = idSnap.value as? String else {
          print("Incorrect format of value at \(idSnap.ref):\n\t\(idSnap.value)")
          
          completion(error: .InvalidFormat, nil)
          return
        }
        let user = Team.Member(username: username)
        
        FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) -> Void in
          guard let userDict = userSnap.value as? [String : AnyObject] else {
            print("\(username) does not have a team branch or name")
            
            completion(error: .InvalidFormat, nil)
            return
          }
          
          user.name = userDict["name"] as! String?
//          let teamsDict = userDict["teams"] as? [String : AnyObject]
          let memberships = Array((userDict["teams"] as! [String : AnyObject]).keys)
          completion(error: nil, CurrentLoggedInUserDetails(uid: authData.uid, member: user, memberships: memberships))
        })
      })
    }
  }
}