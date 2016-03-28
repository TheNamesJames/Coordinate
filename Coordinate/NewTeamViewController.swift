//
//  NewTeamViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 26/02/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class NewTeamViewController: UIViewController {
  
  enum Scene {
    case TeamName
    case TeamID
    case Username
  }
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/testusers/teams")
  var scene: NewTeamViewController.Scene = .TeamName
//  var newTeam: Team!
  
  @IBOutlet private weak var input: UITextField!
  @IBOutlet private weak var helpLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    switch self.scene {
    case .TeamName:
      self.input.placeholder = "Name your team"
      self.helpLabel.text = "Choose a memorable, descriptive name for your team.\nYou can change this later."
      
//      self.newTeam = Team()
      
    case .TeamID:
      self.input.placeholder = "Get a unique team name"
      self.helpLabel.text = "This is used by you and your team members to sign into your team.\nThis must contain only lowercase letters, numbers, hyphens and underscores."
      
    case .Username:
      self.input.placeholder = "Choose a username"
      self.helpLabel.text = "This uniquely identifies you within your team. You may use different usernames across teams.\nThis must contain only lowercase letters, numbers, hyphens and underscores."
      
      let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(NewTeamViewController.donePressed(_:)))
      self.navigationItem.rightBarButtonItem = doneButton
    }
    self.helpLabel.sizeToFit()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func nextPressed(sender: AnyObject) {
    print("nextPressed")
    if self.scene == .TeamID {
      // Check team ID is available
      ref.childByAppendingPath(self.input.text).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
        if !snapshot.exists() {
//          self.newTeam.name = self.input.text
        } else {
//          showError()
        }
      })
    } else {
      self.performSegueWithIdentifier("NewTeamStepSegue", sender: sender)
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
//    self.input.becomeFirstResponder()
  }
  
  func donePressed(sender: AnyObject) {
    // Check username is available
//    let teamName = self.newTeam.name!
//    let username = self.input.text!
//    ref.childByAppendingPath(teamName + "/users/" + username).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
//      if !snapshot.exists() {
//        let teamRef = self.ref.childByAppendingPath(teamName)
//        
//        let usersDict = [username : ["first" : "First", "last" : "Last"]]
//        let teamDict = ["name" : teamName.uppercaseString, "users" : usersDict]
//        
//        teamRef.setValue(teamDict, withCompletionBlock: { (error, url) -> Void in
//          print("saving new team+user at \(url):\n \(error)")
//          self.performSegueWithIdentifier("ShowAllMembersSegue", sender: sender)
//        })
//        
//      }
//    })

  }
  
//  private func setScene(scene: NewTeamViewController.Scene, animated: Bool) {
//    if self.scene == scene {
//      return
//    }
//    UIView.animateWithDuration(0.3, animations: { () -> Void in
//      <#code#>
//      }, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
//  }
  
  
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    print("segue")
    switch segue.identifier! {
    case "NewTeamStepSegue":
      let destinationVC = segue.destinationViewController as! NewTeamViewController
      switch self.scene {
      case .TeamName:
        destinationVC.scene = .TeamID
//        destinationVC.newTeam = self.newTeam
        
      case .TeamID:
        destinationVC.scene = .Username
//        destinationVC.newTeam = self.newTeam
        
      case .Username:
        fatalError("Username should not segue to itself")
      }
      
    case "ShowAllMembersSegue":
      break
      
    case "ShowEventsSegue":
      break
      
    default:
      break
    }
    
  }
  
}
