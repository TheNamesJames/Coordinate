//
//  FirebaseTestViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 08/02/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class FirebaseTestViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    // Create a reference to a Firebase location
    let myRootRef = Firebase(url:"https://dazzling-heat-2970.firebaseio.com")
    
    // create user
    myRootRef.createUser("foobar", password: "password",
      withValueCompletionBlock: { error, result in
        
        if error != nil {
          // There was an error creating the account
          print(error)
          let authError = FAuthenticationError(rawValue: error.code)
          if authError == .None {
            
          }
          
          if let authError = authError {
            switch authError {
              // Dev / Config errors
            case .ProviderDisabled, .InvalidConfiguration, .InvalidOrigin, .InvalidProvider:
              print(error)
              
              // User errors
            case .InvalidEmail:
              print("User email invalid")
            case .InvalidPassword:
              print("User password invalid")
            case .InvalidToken:
              print("User token invalid")
            case .UserDoesNotExist:
              print("User does not exist")
            case .EmailTaken:
              print("User email taken")
              
              // User provider errors (Facebook / Twitter / etc)
            case .DeniedByUser:
              print("User denied \(error)")
            case .InvalidCredentials:
              print("Invalid credentials \(error)")
            case .InvalidArguments:
              print("Invalid args \(error)")
            case .ProviderError:
              print("Provider error \(error)")
            case .LimitsExceeded:
              print("Limit exceeded \(error)")

              // Client errors
            case .NetworkError:
              print("Network error")
            case .Preempted:
              print("Preempted")
              
              // Something else?
            case .Unknown:
              print("Unknown error \(error)")
            }
          } else {
            print("Invalid error code?: \(error)")
          }
        } else {
          if let uid = result["uid"] as? String {
            print("Successfully created user account with uid: \(uid)")
          }
        }
    })
    
//    myRootRef.authUser("himynameisjames@live.co.uk", password: "password") { (error, data) -> Void in
//      if let error = error {
//        print(error)
//      } else {
//        print(data.uid)
//        print(data.providerData["displayName"])
//      }
//    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
