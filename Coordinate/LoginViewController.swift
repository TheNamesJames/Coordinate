//
//  LoginViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 28/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
  
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var confirmTextField: UITextField!
  @IBOutlet weak var hintLabel: UILabel!
  @IBOutlet weak var switchUserType: UIButton!
  @IBOutlet weak var switchUserTypeConstraint: NSLayoutConstraint!
  @IBOutlet weak var textFieldConstraint: NSLayoutConstraint!
  
  private var newUser = true
  
  @IBAction func rightButtonPressed(sender: UIBarButtonItem) {
    if newUser {
      
    } else {
      let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
      let user = usernameTextField.text?.stringByTrimmingCharactersInSet(whitespace)
      let pass = passwordTextField.text?.stringByTrimmingCharactersInSet(whitespace)
      if let user = user where !user.isEmpty,
        let pass = pass where !pass.isEmpty {
          PFUser.logInWithUsernameInBackground(user, password: pass, block: { (user, error) -> Void in
            if let error = error {
              print(error)
              self.hintLabel.text = "Incorrect.. Try again"
            }
          })
      }
    }
  }
  
  @IBAction func switchToExistingUser(sender: AnyObject) {
    if newUser {
      self.navigationItem.rightBarButtonItem?.title = "Login"
      
      if self.firstNameTextField.isFirstResponder() || self.confirmTextField.isFirstResponder() {
        self.usernameTextField.becomeFirstResponder()
      }
      
      UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
        self.firstNameTextField.alpha = 0
        self.confirmTextField.alpha = 0
        }, completion: { (_) -> Void in
      })
      
      UIView.animateWithDuration(0.15, delay: 0.05, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        self.passwordTextField.frame = self.firstNameTextField.frame
        }, completion: { (_) -> Void in
          self.newUser = false
      })
    } else {
      self.navigationItem.rightBarButtonItem?.title = "Sign up"
      
      UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn,  animations: { () -> Void in
        let yDiff = (self.confirmTextField.frame.origin.y - self.firstNameTextField.frame.origin.y) / 2
        let frame = self.passwordTextField.frame.offsetBy(dx: 0.0, dy: yDiff)
        self.passwordTextField.frame = frame
        }, completion: { (_) -> Void in
      })
      
      UIView.animateWithDuration(0.1, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
        self.firstNameTextField.alpha = 1
        self.confirmTextField.alpha = 1
        }, completion: { (_) -> Void in
          self.newUser = true
      })
    }
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curve = UIViewAnimationOptions(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntegerValue)
        
        self.switchUserTypeConstraint.constant = keyboardSize.height + 20
        let minTextFieldHeight = keyboardSize.height + 20 + self.switchUserType.frame.height + 20
        if minTextFieldHeight > self.view.frame.height/2 {
          self.textFieldConstraint.constant = self.view.frame.height/2 - minTextFieldHeight
        }
        
        UIView.animateWithDuration(duration, delay: 0.0, options: curve, animations: { () -> Void in
          self.view.layoutIfNeeded()
          }, completion: nil)
      }
    }
  }
  func keyboardWillHide(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      if let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curve = UIViewAnimationOptions(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntegerValue)
        
        self.switchUserTypeConstraint.constant = 20
        self.textFieldConstraint.constant = 0

        UIView.animateWithDuration(duration, delay: 0.0, options: curve, animations: { () -> Void in
          self.view.layoutIfNeeded()
          }, completion: nil)
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
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

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    switch textField {
    case self.usernameTextField:
      let next = self.newUser ? self.firstNameTextField : self.passwordTextField
      next.becomeFirstResponder()
    case self.firstNameTextField:
      self.passwordTextField.becomeFirstResponder()
    case self.passwordTextField:
      if newUser {
        self.confirmTextField.becomeFirstResponder()
      } else {
        textField.resignFirstResponder()
      }
    case self.confirmTextField:
      textField.resignFirstResponder()
      
    default:
      break
    }
    
    return true
  }
}
