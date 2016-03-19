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
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/")
  
  var currentMember: Team.Member! {
    didSet {
      self.title = "/\(currentMember.username)"
    }
  }
  
  private var data: [Team] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    self.navigationItem.hidesBackButton = true
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    // Lump .ChildAdded callbacks for existing data into a single UI update
//      self.tableView.beginUpdates()
  
    // 1.1: As team IDs become associated with this username..
    self.ref.childByAppendingPath("users/\(self.currentMember.username)/teams").observeEventType(.ChildAdded, withBlock: { (membershipSnap: FDataSnapshot!) -> Void in
      let membership = Team(id: membershipSnap.key, currentMember: self.currentMember)
      let teamID = membershipSnap.key
      
      // 2: Get the team's (descriptive) name for each team ID
      self.ref.childByAppendingPath("teams/\(teamID)/name").observeSingleEventOfType(.Value, withBlock: { (teamSnap: FDataSnapshot!) -> Void in
        guard let teamName = teamSnap.value as? String else {
          print("WARNING: No corresponding team found for \(teamID)")
          return
        }
        
        // 3: If all above successful then add membership to the table view
        membership.name = teamName
        self.data.append(membership)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.data.count-1, inSection: 0)], withRowAnimation: .Automatic)
      })
    })
  
    // 1.2: As team IDs are disassociated from username..
    self.ref.childByAppendingPath("users/\(self.currentMember.username)/teams").observeEventType(.ChildRemoved, withBlock: { (membershipSnap: FDataSnapshot!) -> Void in
      let teamID = membershipSnap.key
      
      // Remove the corresponding `Membership` object from the data source and table view
      if let index = self.data.indexOf({ $0.id == teamID }) {
        self.data.removeAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
      }
    })
    
    // 1.3: .Value is called last, so we know all existing teams have been found. Update table
    self.ref.childByAppendingPath("users/\(self.currentMember.username)/teams").observeSingleEventOfType(.Value, withBlock: { (snap: FDataSnapshot!) -> Void in
      //        self.tableView.endUpdates()
      self.tableView.tableFooterView = UIView()
    })
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    //    let overallHeight = self.view.bounds.height
    //    let minimumHeight = overallHeight - tableView.rowHeight
    ////    let totalRowsHeight = CGFloat(tableView.numberOfRowsInSection(0)) * tableView.rowHeight
    //    var frame = self.tableView.tableFooterView!.frame
    //    frame.size.height = minimumHeight
    //    self.tableView.tableFooterView!.frame = frame
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
    cell.textLabel?.text = membership.name ?? "<Unnamed Team>"
    cell.detailTextLabel?.text = "/\(membership.id)"
    
    return cell
  }
  
  
//  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//    let overallHeight = self.view.bounds.height
//    let minimumHeight = overallHeight - tableView.rowHeight
////    let totalRowsHeight = CGFloat(tableView.numberOfRowsInSection(0)) * tableView.rowHeight
//    
//    return minimumHeight / 2
//  }
//  
//  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//    var frame = tableView.bounds
//    frame.size.height = self.tableView(self.tableView, heightForFooterInSection: section)
//    let view = UIView(frame: frame)
//    view.backgroundColor = UIColor.redColor()
//    
//    return view
//  }
  
  // MARK: - UITableViewDelegate
  
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
    if segue.identifier == "chooseTeam" {
      let destination = segue.destinationViewController as! MainViewController
      if let cell = sender as? UITableViewCell {
        let index = self.tableView.indexPathForCell(cell)!.row
        destination.team = self.data[index]
      } else {
        // New Team button pressed
        destination.team = nil
      }
    }
    
    
//    if segue.identifier == "ShowTeamMapSegue" {
//      let index = self.tableView.indexPathForSelectedRow!
//      let teamID = self.data[index.row].teamID
//      let teamName = self.data[index.row].teamName
//      
//      // FIXME: Just send team ID? perhaps create Team object with a callback to set destination.data..
//      let destination = segue.destinationViewController as! TeamViewController
//      var team = Team(id: teamID, currentMember: Team.Member(username: self.username))
//      team.name = teamName
//      destination.team = team
//      destination.title = "/\(team.id)"
//    }
  }
  
}
