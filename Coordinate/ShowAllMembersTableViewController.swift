//
//  ShowAllMembersTableViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 26/02/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class ShowAllMembersTableViewController: UITableViewController {
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/testusers/teams")
  
  var data: [Team] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    ref.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
      let childrenSnapshots = snapshot.children.generate()
      while let teamSnapshot = childrenSnapshots.next() as? FDataSnapshot {
        var users: [Team.Member] = []
        let allUsersSnapshot = teamSnapshot.childSnapshotForPath("users").children.generate()
        while let userSnapshot = allUsersSnapshot.next() as? FDataSnapshot {
          let userDictionary = userSnapshot.value as! NSDictionary
          
//          var user = Member()
//          user.username = userSnapshot.key
//          user.first = userDictionary["first"] as? String
//          user.last = userDictionary["last"] as? String
//          
//          users.append(user)
        }
        
        
//        var team = Team()
//        team.id = teamSnapshot.key
//        team.name = teamSnapshot.childSnapshotForPath("name").value as? String
//        team.members = users
//        
//        self.data.append(team)
      }
      self.tableView.reloadData()
    })
    
//    51.508131, -0.075949
    let test = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/testusers/locations/photon/barney")
    test.childByAutoId().setValue(["lat" : 51.508131, "lon" : -0.085949])
    
//    ref.authUser("himynameisjames@live.co.uk", password: "password") { (error: NSError!, authData: FAuthData!) -> Void in
//      if let error = error {
//        print(error)
//      } else {
//        print("Successfully authenticated with UID: \(authData.uid)")
//        let user = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/testusers/membership").childByAppendingPath(authData.uid)
//        user.observeEventType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
//          // If membership
//          if snapshot.exists() {
//            let membershipSnapshots = snapshot.children.generate()
//            while let membership = membershipSnapshots.next() as? FDataSnapshot {
//              print("  member of \(membership.key) :: \(membership.value)")
//            }
//          }
//        })
//      }
//    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.data.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let team = self.data[section]
    return team.members.count ?? 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell", forIndexPath: indexPath)
    
    let team = self.data[indexPath.section]
    if team.members.count > 0 {
      let member = team.members[indexPath.row]
      
      cell.textLabel?.text = member.username
      cell.detailTextLabel?.text = member.name ?? "Mr No Name"
    } else {
      cell.textLabel?.text = "This team has no members"
      cell.detailTextLabel?.text = nil
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let team = self.data[section]
    return team.name
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
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
