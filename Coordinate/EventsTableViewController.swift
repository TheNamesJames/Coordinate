//
//  EventsTableViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 20/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import CoreLocation

public struct Event {
  let name: String
  let members: [Member]
}

class EventsTableViewController: UITableViewController {
  
  var data: [Event]
  
  required init?(coder aDecoder: NSCoder) {
    let john = Member(name: "John", location: CLLocationCoordinate2D(latitude: 51.515372, longitude: -0.141880))
    let joe = Member(name: "Joe", location: CLLocationCoordinate2D(latitude: 51.521958, longitude: -0.046652))
    let bob = Member(name: "Bob", location: CLLocationCoordinate2D(latitude: 51.522525, longitude: -0.041899))
    data = [Event(name: "Photon", members: [john, joe, bob])]
    
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    return self.data.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventTableViewCell
    
    let event = self.data[indexPath.row]
    cell.imageView?.image = UIImage(named: event.name)
    cell.textLabel?.text = event.name
    
    if cell.contactImages.count < event.members.count {
      var referenceContactImage: UIImageView! = nil
      for imageView in cell.contactImages {
        if imageView.tag == 1 {
          referenceContactImage = imageView
          break
        }
      }
      
      let referenceIndex = cell.contentView.subviews.indexOf(referenceContactImage)
      
      for var i = cell.contactImages.count; i < event.members.count; i++  {
        let newFrame = referenceContactImage.frame.offsetBy(dx: CGFloat(i) * (2*referenceContactImage.frame.width/3), dy: 0.0)
        let newContactImage = UIImageView(frame: newFrame)
        cell.contactImages.append(newContactImage)
        cell.contentView.insertSubview(newContactImage, atIndex: referenceIndex! + i)
      }
    }
    
    cell.contactImages.sortInPlace { $0.tag < $1.tag }
    
    for (index, member) in event.members.enumerate() {
      cell.contactImages[index].image = UIImage(named: member.name)
//      cell.contactImages[index].layer.zPosition = CGFloat(index) + 1.0
    }
    
    cell.contactImages.forEach { (contactImageView) -> () in
      contactImageView.layer.cornerRadius = contactImageView.frame.width/2
      contactImageView.clipsToBounds = true
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
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    print(sender)
    if segue.identifier == "ShowEventSegue" {
      let destinationVC = segue.destinationViewController as! ViewController
      if let cell = sender as? UITableViewCell {
        let indexSelected = self.tableView.indexPathForCell(cell)!
        destinationVC.title = self.data[indexSelected.row].name
        destinationVC.data = self.data[indexSelected.row].members
      } else {
        destinationVC.data = []
      }
      
    }
  }
  
  
}
