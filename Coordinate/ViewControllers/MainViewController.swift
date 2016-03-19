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
  
  var currentMember: Team.Member! {
    didSet {
      self.membersDrawVC!.currentMember = currentMember
    }
  }
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
    
    getCurrentMemberWithCompleteBlock { (uid, current, teams) -> Void in
      let defaults = NSUserDefaults.standardUserDefaults()
      if let teamID = defaults.stringForKey(kPreviouslySelectedTeamIDKey) {
        print(teamID)
        let team = Team(id: teamID, currentMember: current)
        FIREBASE_ROOT_REF.childByAppendingPath("teams/\(teamID)/name").observeSingleEventOfType(.Value, withBlock: { (teamSnap: FDataSnapshot!) -> Void in
          if teamSnap.exists() {
            team.name = teamSnap.value as! String?
          }
          self.team = team
        })
      }
      
      self.currentMember = current
      print(teams)
    }
//    if let uid = FIREBASE_ROOT_REF.authData?.uid {
//      FIREBASE_ROOT_REF.childByAppendingPath("identifiers/\(uid)").observeSingleEventOfType(.Value, withBlock: { (idSnap) -> Void in
//        guard let username = idSnap.value as? String else {
//          return
//        }
//        let user = Team.Member(username: username)
//        
//        FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) -> Void in
//          guard let userDict = userSnap.value as? [String : AnyObject] else {
//            print("\(username) does not have a team branch or name")
//            self.currentMember = user
//            return
//          }
//          
//          user.name = userDict["name"] as! String?
//          self.currentMember = user
//        })
////        FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)/teams").observeSingleEventOfType(.Value, withBlock: { (teamsSnap) -> Void in
////          print(teamsSnap.value)
////        })
//      })
//    }
    
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
    if segue.identifier == "ShowMemberships" {
      let destination = segue.destinationViewController as! MembershipTableViewController
      destination.currentMember = self.currentMember
    }
  }
  
  // MARK: - Unwind segue actions
  
  @IBAction func addMember(sender: UIStoryboardSegue) {
    // TODO: get/update self.team
//    self.team = (sender.destinationViewController as! AddMemberTableViewController).team
  }

  @IBAction func chooseTeam(sender: UIStoryboardSegue) {
    // TODO: get/update self.team
    // self.team = selectedRow.team?
//    self.team = (sender.destinationViewController as! AddMemberTableViewController).team

    let defaults = NSUserDefaults.standardUserDefaults()
    if let teamID = self.team?.id {
      defaults.setObject(teamID, forKey: kPreviouslySelectedTeamIDKey)
    } else {
      defaults.setObject(nil, forKey: kPreviouslySelectedTeamIDKey)
    }
  }
}
