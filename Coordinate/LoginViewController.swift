//
//  LoginViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 28/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/testusers/teams")
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet var loginBarButton: UIBarButtonItem!
//  @IBOutlet weak var loginModeControl: UISegmentedControl!
  
  
//  @IBAction func checkEmail(sender: UITextField) {
//    let emails = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/emails")
//    emails.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
//      if let email = sender.text?.stringByReplacingOccurrencesOfString(".", withString: ",") where email != "" {
//        if snapshot.hasChild(email) {
//          self.emailTextField.textColor = UIColor.orangeColor()
//        } else {
//          self.emailTextField.textColor = nil
//        }
//      } else {
//        self.emailTextField.textColor = UIColor.redColor()
//      }
//      }) { (error) -> Void in
//        print(error)
//    }
//  }
  
  @IBAction func editingChanged() {
    if let email = emailTextField.text where email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "",
      let password = passwordTextField.text where password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
        self.navigationItem.rightBarButtonItem?.enabled = true
    } else {
      self.navigationItem.rightBarButtonItem?.enabled = false
    }
  }
  
  @IBAction func quickLogin(sender: UIButton) {
    let email: String
    if sender.titleLabel?.text == "fred" {
      email = "himynameisjames@live.co.uk"
    } else { // "barney"
      email = "himynameisjamesw@gmail.com"
    }
    let password = "password"
    
    self.emailTextField.text = email
    self.passwordTextField.text = password
    
    self.loginPressed(UIBarButtonItem())
  }
  
  @IBAction func loginPressed(sender: UIBarButtonItem) {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    spinner.hidesWhenStopped = true
    spinner.startAnimating()
    self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: spinner), animated: true)
//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    
    
    if let email = emailTextField.text where email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "",
    let password = passwordTextField.text where password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != "" {
      ref.authUser(email, password: password, withCompletionBlock: { (error: NSError!, authData: FAuthData!) -> Void in
        if let error = error {
          print(error)
          // Stop spinner and replace with disabled login button
          spinner.stopAnimating()
          self.loginBarButton.enabled = false
          self.navigationItem.setRightBarButtonItem(self.loginBarButton, animated: true)
        } else {
          self.performSegueWithIdentifier("ShowMembership", sender: sender)
        }
      })
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
//    ref.createUser("himynameisjamesw@gmail.com", password: "password") { (error: NSError!, userDict: [NSObject : AnyObject]!) -> Void in
//      if let error = error {
//        print(error.description)
//      } else {
//        print(userDict)
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

//extension LoginViewController: UITextFieldDelegate {
//  func textFieldShouldReturn(textField: UITextField) -> Bool {
//    
//    var shouldReturn = false
//    
//    switch textField {
//    case self.usernameTextField:
//      let next = self.newUser ? self.firstNameTextField : self.passwordTextField
//      next.becomeFirstResponder()
//
//    case self.firstNameTextField:
//      self.passwordTextField.becomeFirstResponder()
//
//    case self.passwordTextField:
//      if newUser {
//        self.confirmTextField.becomeFirstResponder()
//      } else {
//        textField.resignFirstResponder()
//        shouldReturn = true
//      }
//    case self.confirmTextField:
//      textField.resignFirstResponder()
//      shouldReturn = true
//      
//    default:
//      break
//    }
//    
//    if !shouldReturn {
//      textField.setNeedsLayout()
//      textField.layoutIfNeeded()
//    }
//    
//    return shouldReturn
//  }
//}
