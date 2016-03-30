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
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/")
  
  @IBOutlet var loginButton: UIButton!
  
  @IBOutlet var switchHelpLabel: UILabel!
  @IBOutlet var tableView: UITableView!
  private var signupMode = false
  private let loginPlaceholders = ["Your email address", "Your password", "", ""]
  private let signupPlaceholders = ["Your email address", "Enter a password", "Choose a username", "What's your name?"]
  private var items: [TextFieldTableViewCell.ListItem] = [] // email / password / username / full name
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for _ in 0..<4 {
      let item = TextFieldTableViewCell.ListItem()
      self.items.append(item)
    }
    
    self.automaticallyAdjustsScrollViewInsets = false // Prevent tableView gaining content inset
    
    let cell = UINib(nibName: "TextFieldTableViewCell", bundle: nil)
    self.tableView.registerNib(cell, forCellReuseIdentifier: "textfieldCell")
    
    let footer = UINib(nibName: "LoginFooter", bundle: nil)
    self.tableView.registerNib(footer, forHeaderFooterViewReuseIdentifier: "LoginFooter")
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: animated, scrollPosition: .Top)
  }
  
  override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
    return .Portrait
  }

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
  
  @IBAction func switchMode(sender: UITapGestureRecognizer) {
    if self.signupMode {
      self.signupMode = false
      self.switchHelpLabel.text = "Don't have an account? Sign up"
      
        self.tableView.beginUpdates()
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0), NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Fade)
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        self.tableView.endUpdates()
    } else {
      self.signupMode = true
      self.switchHelpLabel.text = "Already got an account? Login"
      
        self.loginButton.alpha = 0.0
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0), NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Fade)
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Fade)
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        self.tableView.endUpdates()
      
    }
    self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .Top)
  }
  
  @IBAction func editingChanged() {
    self.loginButton.enabled = self.validateItems()
  }
  
  private func validateItems() -> Bool {
    let email     = self.items[0].text
    let password  = self.items[1].text
    
    guard self.validateEmail(email, andPassword: password) else {
      return false
    }
    
    if signupMode {
      let username  = self.items[2].text
      let fullname  = self.items[3].text
      guard self.validateUsername(username, andFullName: fullname) else {
        return false
      }
    }
    
    return true
  }

  private func validateEmail(email: String, andPassword pass: String) -> Bool {
    if email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
      return false
    }
    if pass.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
      return false
    }
    
    return true
  }
  private func validateUsername(user: String, andFullName name: String) -> Bool {
    if user.stringByTrimmingCharactersInSet(NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
      return false
    }
    let invalidUsernameChars = NSCharacterSet(charactersInString: ".$#[]/")
    if let _ = user.rangeOfCharacterFromSet(invalidUsernameChars) {
      return false
    }
    
    if name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
      return false
    }
    
    return true
  }
  
  @IBAction func loginPressed(sender: UIButton) {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    spinner.hidesWhenStopped = true
    spinner.startAnimating()
    spinner.center = self.loginButton.center
    self.loginButton.addSubview(spinner)
    self.loginButton.titleLabel!.alpha = 0.0
    
    self.switchHelpLabel.userInteractionEnabled = false
    for cell in self.tableView.visibleCells as! [TextFieldTableViewCell] {
      cell.textField.enabled = false
    }
    
    // Stop spinner and replace with disabled login button
    let complete: Void -> Void = {
      [weak self] in
      spinner.stopAnimating()
      self?.loginButton.titleLabel?.alpha = 1.0
      self?.loginButton.enabled = false
      spinner.removeFromSuperview()
      
      self?.switchHelpLabel.userInteractionEnabled = true
      for cell in self?.tableView.visibleCells as! [TextFieldTableViewCell] {
        cell.textField.enabled = true
      }
    }
    
    let email = self.items[0].text
    let password = self.items[1].text
    
    guard validateItems() else {
      complete()
      return
    }
    
    if signupMode {
      let username = self.items[2].text
      let fullname = self.items[3].text
      
      self.ref.childByAppendingPath("users/\(username)").observeSingleEventOfType(.Value, withBlock: { (snap: FDataSnapshot!) -> Void in
        guard !snap.exists() else {
          complete()
          return
        }
        self.signup(email, password, username, fullname, complete: complete)
      })
    } else {
      login(email, password, complete: complete)
    }
  }
  
  private func signup(email: String, _ password: String, _ username: String, _ fullname: String, complete: (Void -> Void)) {
    self.ref.createUser(email, password: password, withValueCompletionBlock: { (error: NSError!, userDict: [NSObject : AnyObject]!) -> Void in
      if let error = error {
        print(error)
        complete()
        return
      }
      
      // Add /users/username branch if doesn't exist
      self.ref.childByAppendingPath("users/\(username)").runTransactionBlock({ (currentData: FMutableData!) -> FTransactionResult! in
        // Ensure nothing exists at this branch
        guard currentData.value as! NSObject == NSNull() else {
          return FTransactionResult.abort()
        }
        currentData.value = ["name" : fullname]
        return FTransactionResult.successWithValue(currentData)
        
        }, andCompletionBlock: { (error: NSError!, committed: Bool, finalData: FDataSnapshot!) -> Void in
          //            print("Completion:: error:\(error)\n    :: committed:\(committed)\n    :: finalData\(finalData)")
          
          // If above committed, add uid:username reference pair
          if committed {
            let uid = userDict["uid"] as! String
            self.ref.childByAppendingPath("identifiers/\(uid)").setValue(username, withCompletionBlock: { (error: NSError!, _: Firebase!) -> Void in
              // If can't set uid:username reference pair, undo above work
              guard error == nil else {
                print(error)
                self.ref.childByAppendingPath("users/\(username)").removeValue()
                complete()
                return
              }
              
              self.login(email, password, complete: complete)
            })
          } else {
            complete()
          }
        }, withLocalEvents: false)
    })
  }
  
  private func login(email:String, _ password: String, complete: (Void -> Void)) {
    FirebaseLoginHelpers.currentMember = nil
    FirebaseLoginHelpers.initialMemberships = []
    FirebaseLoginHelpers.userDefaultsForPreviouslySelectedTeamID = nil
    
    ref.authUser(email, password: password, withCompletionBlock: { (error: NSError!, authData: FAuthData!) -> Void in
      if let error = error {
        print(error)
        complete()
        UIAlertController.showAlertWithTitle("Invalid login", message: "Could not log you in.", onViewController: self.navigationController!)
      } else {
        let nav = self.storyboard!.instantiateInitialViewController() as! UINavigationController
        nav.modalTransitionStyle = .CrossDissolve
        self.presentViewController(nav, animated: true, completion: { () -> Void in
          let appDelegate = UIApplication.sharedApplication().delegate
          appDelegate?.window!?.rootViewController = nav
        })
      }
    })
  }
  
//  @IBAction func logout(sender: UIStoryboardSegue) {
//    self.navigationItem.rightBarButtonItem = loginBarButton
//    self.ref.unauth()
//  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

extension LoginViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.signupMode ? 4 : 2
//    return 2
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("textfieldCell") as! TextFieldTableViewCell
    
    cell.textField.addTarget(self, action: #selector(LoginViewController.editingChanged), forControlEvents: .EditingChanged)
    cell.textField.placeholder = self.signupMode ? self.signupPlaceholders[indexPath.row] : self.loginPlaceholders[indexPath.row]
    cell.listItem = self.items[indexPath.row]
    
    if self.signupMode {
      cell.textField.placeholder = self.signupPlaceholders[indexPath.row]
    } else {
      cell.textField.placeholder = self.loginPlaceholders[indexPath.row]
    }
    
    switch indexPath.row {
    case 0:
      cell.textField.keyboardType = .EmailAddress
    case 1:
      cell.textField.keyboardType = .ASCIICapable
    case 2:
      cell.textField.keyboardType = .Twitter
    case 3:
      cell.textField.keyboardType = .ASCIICapable
    default:
      break
    }
    cell.textField.secureTextEntry = indexPath.row == 1
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 48
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterViewWithIdentifier("LoginFooter") as! LoginFooterView
  }
  
  func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    let footer = view as! LoginFooterView
    self.loginButton = footer.button
    footer.contentView.alpha = 1.0
    footer.button.setTitle(self.signupMode ? "Sign up" : "Login", forState: .Normal)
    footer.button.addTarget(self, action: #selector(LoginViewController.loginPressed(_:)), forControlEvents: .TouchUpInside)
  }
}
