//
//  MainViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 10/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

  @IBOutlet var membersDrawContainer: UIView!
  var membersDrawVC: MembersDrawViewController!
  var membersMapVC: TeamMapViewController!
  
  var team: Team? {
    didSet {
      if let team = self.team {
        self.title = "#\(team.id)"
      } else {
        self.title = "Unnamed Team"
      }
      
      self.membersDrawVC?.team = self.team
      self.membersMapVC?.team = self.team
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    if let uid = rootRef.authData?.uid {
      rootRef.childByAppendingPath("identifiers/\(uid)").observeSingleEventOfType(.Value, withBlock: { (idSnap) -> Void in
        guard let username = idSnap.value as? String else {
          return
        }
        rootRef.childByAppendingPath("users/\(username)/teams").observeSingleEventOfType(.Value, withBlock: { (teamsSnap) -> Void in
          print(teamsSnap.value)
        })
      })
    }
    
//    self.membersDrawContainer.layer.borderWidth = 1
//    self.membersDrawContainer.layer.borderColor = UIColor.blackColor().CGColor
    self.membersDrawContainer.layer.shadowColor = UIColor.blackColor().CGColor
    self.membersDrawContainer.layer.shadowOpacity = 0.2
    
//    let member = Team.Member(username: "fred")
//    self.team = Team(id: "photon", currentMember: member)
    
    self.membersDrawVC.addPreviewMemberListener(self.membersMapVC)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func logoutPressed(sender: UIBarButtonItem) {
    unauthAndDismissToLoginFrom(self.navigationController!)
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "EmbedMembersDraw" {
      let destination = segue.destinationViewController as! MembersDrawViewController
      self.membersDrawVC = destination
    }
    if segue.identifier == "EmbedMembersMap" {
      let destination = segue.destinationViewController as! TeamMapViewController
      self.membersMapVC = destination
    }
    if segue.identifier == "AddMember" {
      let destination = segue.destinationViewController as! AddMemberTableViewController
      destination.team = self.team
    }
  }
  
  @IBAction func addMember(sender: UIStoryboardSegue) {
    // TODO: get/update self.team
//    self.team = (sender.destinationViewController as! AddMemberTableViewController).team
  }

}
