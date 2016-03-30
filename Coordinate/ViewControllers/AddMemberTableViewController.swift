//
//  AddMemberTableViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 18/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

class AddMemberTableViewController: UITableViewController {
  
  private let placeholders = ["What's their username?", "Choose a team ID", "Enter a team name"]
  private var usernameItems: [TextFieldTableViewCell.ListItem] = []
  private var teamItems: [TextFieldTableViewCell.ListItem]!
  
  var currentMember: Team.Member!
  var team: Team?
  var createdTeamID: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    let cell = UINib(nibName: "TextFieldTableViewCell", bundle: nil)
    self.tableView.registerNib(cell, forCellReuseIdentifier: "textfieldCell")
    
    self.tableView.registerClass(TitleHeaderView.self, forHeaderFooterViewReuseIdentifier: "TitleHeader")
    
    self.tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "BlankFooter")
    
    let footer = UINib(nibName: "LoginFooter", bundle: nil)
    self.tableView.registerNib(footer, forHeaderFooterViewReuseIdentifier: "LoginFooter")

    
    for _ in 0..<1 {
      let item = TextFieldTableViewCell.ListItem()
      self.usernameItems.append(item)
    }
    
    self.teamItems = [TextFieldTableViewCell.ListItem(), TextFieldTableViewCell.ListItem()]
    
    
    self.tableView.tableHeaderView = self.tableView.tableFooterView
    
    self.tableView.tableFooterView = UIView() // Hide remaining separators
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.team == nil ? 2 : 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? usernameItems.count : 2
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("textfieldCell") as! TextFieldTableViewCell
    
    cell.textField.addTarget(self, action: #selector(AddMemberTableViewController.editingChanged), forControlEvents: .EditingChanged)
    switch indexPath.section {
    case 0:
      cell.textField.placeholder = self.placeholders[0]
      cell.listItem = self.usernameItems[indexPath.row]
      
    case 1 where indexPath.row == 0:
      cell.textField.placeholder = self.placeholders[1]
      cell.listItem = self.teamItems[indexPath.row]
    case 1 where indexPath.row == 1:
      cell.textField.placeholder = self.placeholders[2]
      cell.listItem = self.teamItems[indexPath.row]
      
    default:
      break
    }
    
    return cell
  }
  
  func editingChanged() {
    self.navigationItem.rightBarButtonItem!.enabled = self.validateItems()
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 36
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterViewWithIdentifier("TitleHeader")
  }
  
  override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView//TitleHeaderView
    header.contentView.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
    header.textLabel!.text = section == 0 ? "Add a member to your team" : "By the way, you need to create a team…"
    header.textLabel!.textColor = UIColor(white: 0.9, alpha: 1.0)
  }

  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    // If last section footer (i.e. button)
    if section == tableView.numberOfSections - 1 {
      return 48
    }
    
    return 36
  }
  
  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if section == tableView.numberOfSections - 1 {
      return tableView.dequeueReusableHeaderFooterViewWithIdentifier("LoginFooter") as! LoginFooterView
    } else {
      return tableView.dequeueReusableHeaderFooterViewWithIdentifier("BlankFooter")
    }
  }
  
  override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    if section == tableView.numberOfSections - 1 {
      let footer = view as! LoginFooterView
      footer.contentView.alpha = 1.0
      
      let title = self.team == nil ? "Create team and Add member" : "Add member"
      footer.button.setTitle(title, forState: .Normal)
      // TODO: replace w/ validate check
      footer.button.enabled = true
      footer.button.addTarget(self, action: #selector(AddMemberTableViewController.donePressed(_:)), forControlEvents: .TouchUpInside)
    } else {
      let footer = view as! UITableViewHeaderFooterView
      footer.contentView.backgroundColor = UIColor.clearColor()
    }
  }
  
  @IBAction func donePressed(sender: AnyObject) {
    if let team = self.team {
      self.addMembersToTeamID(team.id)
    } else {
      let teamID = self.teamItems.first!.text
      let teamName = self.teamItems.last!.text

      if self.validateCreateTeamID(teamID, teamName: teamName) {
        self.createTeamWithID(teamID, teamName: teamName)
      }
    }
  }
  
  private func addMembersToTeamID(teamID: String) {
    var usernames = [String]()
    var invalidUsernames = [String]()
    for item in self.usernameItems {
      if item.text.stringByTrimmingCharactersInSet(NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
        UIAlertController.showAlertWithTitle("Invalid member username", message: "Member username left blank", onViewController: self)
        invalidUsernames.append(item.text)
      } else {
        usernames.append(item.text)
      }
    }
    
    if invalidUsernames.count > 0 {
      UIAlertController.showAlertWithTitle("Invalid member username\(invalidUsernames.count > 1 ? "s" : "")", message: invalidUsernames.reduce("", combine: { "\($0!)\n\($1)" }), onViewController: self)
      return
    } else if usernames.count > 0 {
      self.addMembers(usernames, toTeam: teamID)
    } else {
      // No members to add
      self.performSegueWithIdentifier("doneAddingMember", sender: self)
    }
  }
  
  private func addMembers(usernames: [String], toTeam teamID: String) {
    // Check for invalid usernames
    for username in usernames {
//      if username.stringByTrimmingCharactersInSet(NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
//        return
//      }
      let invalidUsernameChars = NSCharacterSet(charactersInString: ".$#[]/")
      if let _ = username.rangeOfCharacterFromSet(invalidUsernameChars) {
        UIAlertController.showAlertWithTitle("Invalid member username", message: "Member usernames do not have the characters .$#[]/", onViewController: self)
        return
      }
    }
    
    let username = usernames.first!
    FIREBASE_ROOT_REF.childByAppendingPath("users/\(username)").observeSingleEventOfType(.Value) { (memberSnap: FDataSnapshot!) -> Void in
      if memberSnap.exists() {
        FIREBASE_ROOT_REF.updateChildValues([
          "teams/\(teamID)/members/\(username)": true,
          "users/\(username)/teams/\(teamID)": true
          ])
        self.performSegueWithIdentifier(self.createdTeamID == nil ? "doneAddingMember" : "chooseTeam", sender: self)
      } else {
        UIAlertController.showAlertWithTitle("Member doesn't exist", message: "/\(username) does not exist", onViewController: self)
      }
    }
  }
  
  func validateItems() -> Bool {
    if self.team == nil {
      let teamID = self.teamItems.first!.text
      let teamName = self.teamItems.last!.text
      
      if !validateCreateTeamID(teamID, teamName: teamName) {
        return false
      }
    }
    
    let invalidUsernameChars = NSCharacterSet(charactersInString: ".$#[]/")
    for username in self.usernameItems {
      if let _ = username.text.rangeOfCharacterFromSet(invalidUsernameChars) {
        return false
      }
    }
    
    return true
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
    let idRange = Range<String.Index>(teamID.startIndex ..< teamID.endIndex)
    if let _ = teamID.rangeOfCharacterFromSet(invalidChars, options: .LiteralSearch, range: idRange) {
      return false
    }
    
    return true
  }
  
  private func createTeamWithID(teamID: String, teamName: String) {
    FIREBASE_ROOT_REF.childByAppendingPath("teams/\(teamID)").observeSingleEventOfType(.Value, withBlock: { (teamSnap) in
      if teamSnap.exists() {
        let alert = UIAlertController(title: "Team ID already taken", message: "Please try again", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
            self.presentViewController(alert, animated: true, completion: nil)
            return
          }
          
          print("Team created")
          self.createdTeamID = teamID
          self.addMembersToTeamID(teamID)
        })
      }
    })
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
}
