//
//  ParseTestViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 20/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Parse

class ParseTestViewController: UIViewController {
  
  @IBOutlet var textFields: [UITextField]!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var imageView: UIImageView!
  
  
  @IBAction func imageViewTapped(sender: AnyObject?) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false
    picker.sourceType = .PhotoLibrary
    
    self.presentViewController(picker, animated: true, completion: nil)
  }
  
  @IBAction func signupPressed(sender: AnyObject) {
    if let usr = usernameTextField.text where usr != "",
      let pwd = passwordTextField.text where pwd != "",
      let eml = emailTextField.text where eml != "" {
      userSignUp(usr, password: pwd, email: eml)
    } else {
      self.title = "All Fields Required"
      textFields.forEach({ (textField) -> () in
        if let t = textField.text where t != "" {
        } else {
          textField.layer.borderWidth = 1.0
          textField.layer.cornerRadius = 8.0
          textField.layer.borderColor = UIColor.redColor().CGColor
        }
      })
    }
  }
  
  private func userSignUp(username: String, password: String, email: String) {
    let oldRightBarButtonItem = self.navigationItem.rightBarButtonItem
    let spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
    spinner.activityIndicatorViewStyle = .Gray
    let spinnerBarButton = UIBarButtonItem(customView: spinner)
    self.navigationItem.setRightBarButtonItem(spinnerBarButton, animated: true)
    spinner.startAnimating()
    
    
    let user = PFUser()
    user.username = username
    user.password = password
    user.email = email
    
    user.signUpInBackgroundWithBlock { (success, error) -> Void in
      if let error = error {
        print(error)
        self.textFields.forEach({ $0.layer.borderColor = UIColor.redColor().CGColor
        })
      } else {
        print("Success")
        let image = self.imageView.image!
        let imageData = UIImagePNGRepresentation(image)!
        let imageFile = PFFile(name: "\(username).png", data: imageData)!
        imageFile.saveInBackgroundWithBlock({ (success, error) -> Void in
          if let error = error {
            print(error)
          }
        })
        
        
//        PFUser *user = [PFUser currentUser];
        user.setObject(imageFile, forKey: "profilePicture")// setObject:imageFile forKey:@"profilePic"];
        user.saveInBackgroundWithBlock({ (success, error) -> Void in
          if let error = error {
            print(error)
          }
        })
        
        self.navigationItem.setRightBarButtonItem(oldRightBarButtonItem, animated: true)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.imageView.layer.cornerRadius = self.imageView.frame.width/2
    self.imageView.clipsToBounds = true
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

extension ParseTestViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == self.usernameTextField {
      self.passwordTextField.becomeFirstResponder()
    } else if textField == self.passwordTextField {
      self.emailTextField.becomeFirstResponder()
    } else {
      // self.emailTextField
      self.emailTextField.resignFirstResponder()
    }
    return true
  }
  
  
  @IBAction func editingChanged(sender: AnyObject) {
    var ready = true
//    for textField in self.textFields {
      if let usr = usernameTextField.text where usr != "",
        let pwd = passwordTextField.text where pwd != "",
        let eml = emailTextField.text where eml != "" {
          //userSignUp(usr, password: pwd, email: eml)
      } else {
        ready = false
//        break
      }
//    }
    self.navigationItem.rightBarButtonItem?.enabled = ready
  }
}

extension ParseTestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.imageView.contentMode = .ScaleAspectFit
      self.imageView.image = pickedImage
    }
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
