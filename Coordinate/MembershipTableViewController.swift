//
//  MembershipTableViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 02/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class MembershipTableViewController: UITableViewController {
  
  struct Membership {
    let teamID: String
    var teamName: String?
  }
  
  @IBOutlet var signedInLabel: UILabel!
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/")
  
  var username: String! {
    didSet {
      self.signedInLabel?.text = "Signed in as \(username)"
    }
  }
  var data: [Membership] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    // Show all the teams the logged in user is a member of
    // 1: Get user's username
    ref.childByAppendingPath("identifiers/\(ref.authData.uid)").observeSingleEventOfType(.Value) { (uidSnap: FDataSnapshot!) -> Void in
      guard let username = uidSnap.value as? String else {
        print("WARNING: No corresponding username found for uid \(uidSnap.key)")
        return
      }
      
      self.username = username
      
      // 2.1: As team IDs become associated with this username..
      self.ref.childByAppendingPath("users/\(username)/teams").observeEventType(.ChildAdded, withBlock: { (membershipSnap: FDataSnapshot!) -> Void in
        var membership = Membership(teamID: membershipSnap.key, teamName: nil)
        let teamID = membershipSnap.key
        
        // 3: Get the team's (descriptive) name for each team ID
        self.ref.childByAppendingPath("teams/\(teamID)/name").observeEventType(.Value, withBlock: { (teamSnap: FDataSnapshot!) -> Void in
          guard let teamName = teamSnap.value as? String else {
            print("WARNING: No corresponding team found for \(teamID)")
            return
          }
          
          // 4: If all above successful then add membership to the table view
          membership.teamName = teamName
          self.data.append(membership)
          self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.data.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
      })
      // 2.2: As team IDs are disassociated from username..
      self.ref.childByAppendingPath("users/\(username)/teams").observeEventType(.ChildRemoved, withBlock: { (membershipSnap: FDataSnapshot!) -> Void in
        let teamID = membershipSnap.key
//        let index = self.data.indexOf({ (membership) -> Bool in
//          membership.teamID == teamID
//        })
//        if let index = index {
        // Remove the corresponding `Membership` object from the data source and table view
        if let index = self.data.indexOf({ $0.teamID == teamID }) {
          self.data.removeAtIndex(index)
          self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
      })
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.data.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MembershipCell", forIndexPath: indexPath)
    
    // Configure the cell...
    let membership = self.data[indexPath.row]
    cell.textLabel?.text = membership.teamName
    cell.detailTextLabel?.text = "/\(membership.teamID)"
    
    return cell
  }
  
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the item to be re-orderable.
  return true
  }
  */
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "ShowTeamMapSegue" {
      let index = self.tableView.indexPathForSelectedRow!
      let teamID = self.data[index.row].teamID
      let teamName = self.data[index.row].teamName
      
      // FIXME: Just send team ID? perhaps create Team object with a callback to set destination.data..
      let destination = segue.destinationViewController as! TeamViewController
      var team = Team(id: teamID, currentMember: Team.Member(username: self.username))
      team.name = teamName
      destination.team = team
      destination.title = "/\(team.id)"
    }
  }
  
}
