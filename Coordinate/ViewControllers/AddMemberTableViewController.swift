//
//  AddMemberTableViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 18/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class AddMemberTableViewController: UITableViewController {
  
  private let placeholders = ["What's their username?", "Choose a team ID", "Enter a team name"]
  private var items: [TextFieldTableViewCell.ListItem] = []
  
  var team: Team?
  
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
      self.items.append(item)
    }
    
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
    return section == 0 ? items.count : 2
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("textfieldCell") as! TextFieldTableViewCell
    
//    cell.textField.addTarget(self, action: "editingChanged", forControlEvents: .EditingChanged)
    switch indexPath.section {
    case 0:
      cell.textField.placeholder = self.placeholders[0]
      cell.listItem = self.items[indexPath.row]
      
    case 1 where indexPath.row == 0:
      cell.textField.placeholder = self.placeholders[1]
    case 1 where indexPath.row == 0:
      cell.textField.placeholder = self.placeholders[2]
      
    default:
      break
    }
    
    return cell
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
      footer.button.addTarget(self, action: "donePressed:", forControlEvents: .TouchUpInside)
    } else {
      let footer = view as! UITableViewHeaderFooterView
      footer.contentView.backgroundColor = UIColor.clearColor()
    }
  }
  
  func donePressed(sender: AnyObject) {
    self.performSegueWithIdentifier("addMember", sender: self)
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