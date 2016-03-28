//
//  LoadingViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 26/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class LoadingViewController: UIViewController {
  
  var currentMember: Team.Member?
  private var team: Team?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    doTheLoadingThing(nil)
  }
  
  private func doTheLoadingThing(chosenTeamID: String?) {
    guard let authData = FIREBASE_ROOT_REF.authData else {
      print("Wasn't logged in somehow @ LoadingViewController")
      FirebaseLoginHelpers.unauthAndDismissToLoginFrom(self.navigationController!)
      return
    }
    FIREBASE_ROOT_REF.childByAppendingPath("identifiers/\(authData.uid)").observeSingleEventOfType(.Value, withBlock: { (idSnap) -> Void in
      guard let username = idSnap.value as? String else {
        print("id -> username pair not found for \(authData.uid)")
        return
      }
      let user = Team.Member(username: username)
      
      FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) -> Void in
        guard let userDict = userSnap.value as? [String : AnyObject] else {
          print("\(username) does not have a team branch or name ∴ doesn't exist..")
          return
        }
        
        user.name = userDict["name"] as! String?
        self.currentMember = user
        
        let teamsDict = userDict["teams"] as? [String : AnyObject]
        var teamIDToLoad: String?
        
        
        if let chosenTeamID = chosenTeamID {
          teamIDToLoad = chosenTeamID
        } else {
          teamIDToLoad = FirebaseLoginHelpers.userDefaultsForPreviouslySelectedTeamID
        }
        
        // Check user is member of team
        if let team = teamIDToLoad {
          if teamsDict?[team] == nil {
            teamIDToLoad = nil // Team does not exist in user's memberships ∴ load nil team
          }
        }
        
        self.loadTeam(teamIDToLoad, completion: { (team: Team?) in
          self.team = team
          FirebaseLoginHelpers.userDefaultsForPreviouslySelectedTeamID = team?.id
          self.performSegueWithIdentifier("ShowTeam", sender: nil)
        })
      })
    })
  }
  
  private func loadTeam(teamID: String?, completion: (Team? -> Void)) {
    print("loading \(teamID)")
    
    if let teamID = teamID {
      FIREBASE_ROOT_REF.childByAppendingPath("teams/\(teamID)/name").observeSingleEventOfType(.Value, withBlock: { (teamSnap: FDataSnapshot!) -> Void in
        let team: Team?
        if teamSnap.exists() {
          team = Team(id: teamID, currentMember: self.currentMember!)
          team!.name = teamSnap.value as! String?
        } else {
          print("Team \(teamID) doesn't exist..")
          team = nil // Team doesn't have a name  doesn't exist..
        }
        completion(team)
      })
    } else {
      // No previously selected team ∴ don't load team
      completion(nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowTeam" {
      let destination = segue.destinationViewController as! MainViewController
      destination.currentMember = self.currentMember
      destination.team = self.team
    }
  }
  
  // MARK: - Unwind segue actions
  
  @IBAction func chooseTeam(sender: UIStoryboardSegue) {
    // TODO: get/update self.team
    // self.team = selectedRow.team?
    //    self.team = (sender.destinationViewController as! AddMemberTableViewController).team
    
    if sender.identifier == "chooseTeam" {
      let source = sender.sourceViewController as! MembershipTableViewController
      let chosenTeamID = source.selectedTeamID
      self.doTheLoadingThing(chosenTeamID)
    }
  }
  
}
