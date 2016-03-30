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
  var selectedTeamID: String?
  
  @IBAction func logoutPressed(sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "Log out", message: "Are you sure?", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { (_) in
      FirebaseLoginHelpers.unauthAndDismissToLoginFrom(self.navigationController!)
    }))
    self.navigationController!.presentViewController(alert, animated: true, completion: nil)
  }
  
  @IBAction func createTeam(sender: AnyObject) {
    let alert = UIAlertController(title: "Create a new team", message: nil, preferredStyle: .Alert)
    var teamIDTextField: UITextField!
    alert.addTextFieldWithConfigurationHandler { (textfield) in
      textfield.placeholder = "Choose a team ID"
      textfield.keyboardType = .Twitter
      textfield.addTarget(self, action: #selector(MembershipTableViewController.validateTeamIDTextField(_:)), forControlEvents: .EditingChanged)
      teamIDTextField = textfield
    }
    var teamNameTextField: UITextField!
    alert.addTextFieldWithConfigurationHandler { (textfield) in
      textfield.placeholder = "Enter a team name"
      textfield.keyboardType = .ASCIICapable
      textfield.addTarget(self, action: #selector(MembershipTableViewController.validateTeamIDTextField(_:)), forControlEvents: .EditingChanged)
      teamNameTextField = textfield
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    let createAction = UIAlertAction(title: "Create", style: .Default, handler: { (_) in
      let teamID = teamIDTextField.text!
      let teamName = teamNameTextField.text!
      self.createTeamWithID(teamID, teamName: teamName)
    })
    createAction.enabled = false
    alert.addAction(createAction)
    self.navigationController!.presentViewController(alert, animated: true, completion: nil)
  }
  
  func validateTeamIDTextField(sender: UITextField) {
    let alertController = self.presentedViewController as! UIAlertController
    let addTeamAction = alertController.actions.last
    
    let teamID = alertController.textFields!.first?.text ?? ""
    let teamName = alertController.textFields!.last?.text ?? ""
    
    addTeamAction?.enabled = validateCreateTeamID(teamID, teamName: teamName)
  }
  
  private func validateCreateTeamID(teamID: String, teamName: String) -> Bool {
    if teamID.characters.count <= 1 || teamName.characters.count == 0 {
      return false
    }
    
    let invalidChars = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
    invalidChars.removeCharactersInString(" ") // Allow spaces
    if let _ = teamName.rangeOfCharacterFromSet(invalidChars, options: .LiteralSearch, range: Range<String.Index>(teamName.startIndex..<teamName.endIndex)) {
      return false
    }
    
    
    invalidChars.addCharactersInString(".$#[]/")
    let idRange = Range<String.Index>(teamID.startIndex.advancedBy(1) ..< teamID.endIndex)
    if let _ = teamID.rangeOfCharacterFromSet(invalidChars, options: .LiteralSearch, range: idRange) {
      return false
    }
    
    return true
  }
  
  private func createTeamWithID(teamID: String, teamName: String) {
    FIREBASE_ROOT_REF.childByAppendingPath("teams/\(teamID)").observeSingleEventOfType(.Value, withBlock: { (teamSnap) in
      if teamSnap.exists() {
        let alert = UIAlertController(title: "Team ID already taken", message: "Please try again", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Try again", style: .Default, handler: { (action) in
          self.createTeam(action)
        }))
        self.navigationController!.presentViewController(alert, animated: true, completion: nil)
      } else {
        var teamDict = [String : AnyObject]()
        teamDict["teams/\(teamID)/members/\(self.currentMember.username)"] = true
        teamDict["teams/\(teamID)/name"] = teamName
        teamDict["users/\(self.currentMember.username)/teams/\(teamID)"] = true
        
        FIREBASE_ROOT_REF.updateChildValues(teamDict, withCompletionBlock: { (error, firebase) in
          guard error == nil else {
            print(error)
            let alert = UIAlertController(title: "Oops. Something's broke", message: "Could not create team", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.navigationController!.presentViewController(alert, animated: true, completion: nil)
            return
          }
          
          print("Team created")
        })
      }
    })
  }
  
  
  func joinTeam(sender: AnyObject) {
    let alert = UIAlertController(title: "Join a Team", message: nil, preferredStyle: .Alert)
    var teamIDTextField: UITextField!
    alert.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Enter the team ID"
      textField.keyboardType = .Twitter
      textField.addTarget(self, action: #selector(MembershipTableViewController.validateJoinTeamIDTextField(_:)), forControlEvents: .EditingChanged)
      teamIDTextField = textField
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    let joinTeamAction = UIAlertAction(title: "Join", style: .Default) { (action) in
      self.joinTeamWithID(teamIDTextField.text!)
    }
    joinTeamAction.enabled = false
    alert.addAction(joinTeamAction)
    self.navigationController!.presentViewController(alert, animated: true, completion: nil)
  }
  
  func validateJoinTeamIDTextField(sender: UITextField) {
    let alertController = self.presentedViewController as! UIAlertController
    let joinTeamAction = alertController.actions.last
    
    let teamID = sender.text ?? ""
    
    
    let invalidChars = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
    invalidChars.addCharactersInString(".$#[]/")
    
    let validTeamID: Bool
    if teamID.characters.count <= 1 {
      validTeamID = false
    } else if let _ = teamID.rangeOfCharacterFromSet(invalidChars, options: .LiteralSearch, range: Range<String.Index>(teamID.startIndex..<teamID.endIndex)) {
      validTeamID = false
    } else {
      validTeamID = true
    }
    
    joinTeamAction?.enabled = validTeamID
  }
  
  func joinTeamWithID(teamID: String) {
    FIREBASE_ROOT_REF.childByAppendingPath("teams/\(teamID)").observeSingleEventOfType(.Value, withBlock: { (teamSnap) in
      if !teamSnap.exists() {
        UIAlertController.showAlertWithTitle("Team ID does not exist", message: "Hmm. Not much I can do to help here..", onViewController: self)
      } else {
        var teamDict = [String : AnyObject]()
        teamDict["teams/\(teamID)/members/\(self.currentMember.username)"] = true
        teamDict["users/\(self.currentMember.username)/teams/\(teamID)"] = true
        
        FIREBASE_ROOT_REF.updateChildValues(teamDict, withCompletionBlock: { (error, firebase) in
          guard error == nil else {
            print(error)
            let alert = UIAlertController(title: "Oops. Something's broke", message: "Could not join team", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.navigationController!.presentViewController(alert, animated: true, completion: nil)
            return
          }
          
          print("Team joined")
        })
      }
    })
  }
  
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
//      self.tableView.tableFooterView = UIView()
    })
    
    
    let footer = UINib(nibName: "LoginFooter", bundle: nil).instantiateWithOwner(self, options: nil).first as! LoginFooterView
    footer.button.setTitle("Join a Team", forState: .Normal)
    footer.button.enabled = true
    footer.button.addTarget(self, action: #selector(MembershipTableViewController.joinTeam(_:)), forControlEvents: .TouchUpInside)
    self.tableView.tableFooterView = footer
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
    cell.accessoryType = membership.id == self.selectedTeamID ? .Checkmark : .None
    
    return cell
  }
  
  

  
  // MARK: - UITableViewDelegate
  
  
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let team = self.data[indexPath.row]
      
      let alert = UIAlertController(destructiveAlertWithTitle: "Are you sure?", message: "Are you sure you want to leave #\(team.id)?", defaultTitle: "Yes", defaultHandler: { (_) in
        // Delete the row from the data source
        var dict = [String : AnyObject]()
        dict["teams/\(team.id)/members/\(self.currentMember.username)"] = NSNull()
        dict["users/\(self.currentMember.username)/teams/\(team.id)"] = NSNull()
        
        FIREBASE_ROOT_REF.updateChildValues(dict)
      })
      self.navigationController!.presentViewController(alert, animated: true, completion: nil)
    } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  
  override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
    return "Leave"
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
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
//    if segue.identifier == "chooseTeam" {
//      let destination = segue.destinationViewController as! MainViewController
//      if let cell = sender as? UITableViewCell {
//        let index = self.tableView.indexPathForCell(cell)!.row
//        if self.data[index].id != self.selectedTeamID {
//          destination.team = self.data[index]
//        }
//      } else {
//        // New Team button pressed
//        // TODO: Create team, add to self.data and return that.. 
//        destination.team = nil
//      }
//    }
    
    if segue.identifier == "chooseTeam" {
      if let cell = sender as? UITableViewCell {
        let index = self.tableView.indexPathForCell(cell)!.row
//        if self.data[index].id != self.selectedTeamID {
          self.selectedTeamID = self.data[index].id
//        }
      } else {
        // New Team button pressed
        // TODO: Create team, add to self.data and return that..
        self.selectedTeamID = nil
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
