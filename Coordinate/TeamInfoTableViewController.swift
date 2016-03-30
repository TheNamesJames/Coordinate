//
//  TeamMembersTableViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 26/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class TeamInfoTableViewController: UITableViewController {
  
  var currentMember: Team.Member!
  var team: Team!
  
  private var data: [Team.Member] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    FIREBASE_ROOT_REF.childByAppendingPath("teams/\(team.id)/members").observeEventType(.ChildAdded) { (teamMemberSnap: FDataSnapshot!, previousKey: String!) in
      let username = teamMemberSnap.key
      
      FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)/name").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) in
        guard userSnap.exists() else {
          print("\(username) does not exist but is still a member of \(self.team.id)")
          return
        }
        guard let fullname = userSnap.value as? String else {
          print("\(username) does not have a full name??")
          return
        }
        
        let newMember = Team.Member(username: username)
        newMember.name = fullname
        if let prev = previousKey,
          index = self.data.indexOf({ $0.username == prev }) {
          self.data.insert(newMember, atIndex: index.advancedBy(1))
          self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index.advancedBy(1), inSection: 0)], withRowAnimation: .Automatic)
        } else {
          self.data.append(newMember)
          self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.data.count-1, inSection: 0)], withRowAnimation: .Automatic)
        }
      })
    }
    
    FIREBASE_ROOT_REF.childByAppendingPath("teams/\(team.id)/members").observeEventType(.ChildRemoved) { (teamMemberSnap: FDataSnapshot!) in
      let username = teamMemberSnap.key
      
      if let index = self.data.indexOf({ $0.username == username }) {
        self.data.removeAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
      } else {
        print("Member not found in tableview...")
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.data.count
  }
  

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath)
    
    // Configure the cell...
    let member = self.data[indexPath.row]
    cell.textLabel!.text = member.name! + (member.username == self.currentMember.username ? " (You)" : "")
    cell.detailTextLabel!.text = member.username
    
    return cell
  }
  

   // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let member = self.data[indexPath.row]
      if member.username == self.currentMember.username {
        UIAlertController.showAlertWithTitle("You cannot delete yourself from a team", message: nil, onViewController: self)
        return
      }
      
      let alert = UIAlertController(destructiveAlertWithTitle: "Are you sure?", message: "Are you sure you want to remove /\(member.username) from this team?", defaultTitle: "Yes", defaultHandler: { (_) in
        // Delete the row from the data source
        var dict = [String : AnyObject]()
        dict["teams/\(self.team.id)/members/\(member.username)"] = NSNull()
        dict["users/\(member.username)/teams/\(self.team.id)"] = NSNull()
        
        FIREBASE_ROOT_REF.updateChildValues(dict)
      })
      self.presentViewController(alert, animated: true, completion: nil)
    } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  
  override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
    return "Remove"
  }
  
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
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
