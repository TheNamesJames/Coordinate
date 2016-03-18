//
//  AddMemberTableViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 18/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class AddMemberTableViewController: UITableViewController {
  
  private let placeholders = ["What's their email address?", "Choose a team ID", "Enter a team name"]
  private var items: [TextFieldTableViewCell.ListItem] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    let cell = UINib(nibName: "TextFieldTableViewCell", bundle: nil)
    self.tableView.registerNib(cell, forCellReuseIdentifier: "textfieldCell")
    
    for _ in 0..<1 {
      let item = TextFieldTableViewCell.ListItem()
      self.items.append(item)
    }
    
    self.tableView.tableFooterView = UIView() // Hide remaining separators
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // TODO: 2 only if team doesn't exist..
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return section == 0 ? items.count : 2
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("textfieldCell") as! TextFieldTableViewCell
    
    cell.textField.addTarget(self, action: "editingChanged", forControlEvents: .EditingChanged)
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
