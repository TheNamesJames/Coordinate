//
//  MembersTableViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 19/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import MapKit

protocol PreviewMemberListener: NSObjectProtocol {
  func previewMember(member: Member?) //, atZoomLevel: MKZoomScale)
}

class MembersTableViewController: UITableViewController {
  
  weak var mapView: MKMapView? {
    didSet {
      let firstCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
      if let controlCell = firstCell as! LocationControlTableViewCell? {
        controlCell.userTrackingButton.mapView = mapView
      }
    }
  }
  
  private var previewMemberListeners: [PreviewMemberListener] = []
  var data: [Member]!
  
  func addPreviewMemberListener(listener: PreviewMemberListener) {
    self.previewMemberListeners.append(listener)
  }
  
  func removePreviewMemberListener(listener: PreviewMemberListener) {
    if let index = self.previewMemberListeners.indexOf({ $0 === listener }) {
      self.previewMemberListeners.removeAtIndex(index)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    let longPress = UILongPressGestureRecognizer(target: self, action: "longPressed:")
    self.tableView.addGestureRecognizer(longPress)
    
    //    let membersToShow = 3
    //    (self.tableView as! TransparentTableView).membersToShow = membersToShow
    //    let inset = CGFloat(membersToShow) * self.tableView.rowHeight
    let inset = self.tableView.frame.height - CGFloat(4) * self.tableView.rowHeight
    // FIXME: Should auto-scroll to inset initially (i.e. on init?)
    self.tableView.contentInset = UIEdgeInsets(top: inset, left: 0.0, bottom: 0.0, right: 0.0)
    self.tableView.contentOffset = CGPoint(x: 0.0, y: -inset)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  private var previewMemberIndex: Int? = nil
  
  func longPressed(sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .Possible: break
    case .Began:
      let point = sender.locationInView(self.tableView)
      if let indexPath = self.tableView.indexPathForRowAtPoint(point) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
          (self.tableView as! TransparentTableView).backgroundBlurView.effect = nil
          
          self.tableView.visibleCells.forEach({ (visibleCell) -> () in
            // Make all cell contents transparent except for imageView
            visibleCell.contentView.subviews.filter({ !(($0 is UIImageView) || ($0 is UIVisualEffectView)) }).forEach({ $0.alpha = 0.0 })
            visibleCell.textLabel?.alpha = 0.0
            
            var frame = visibleCell.imageView!.frame
            frame.origin.x = (visibleCell == cell) ? 15.0 : -frame.width/2
            visibleCell.imageView!.frame = frame
          })
          
          }, completion: { (finished) -> Void in
            self.previewMemberIndex = indexPath.row
            self.firePreviewMember(self.data[indexPath.row])
        })
      }
    case .Changed:
      let point = sender.locationInView(self.tableView)
      if let indexPath = self.tableView.indexPathForRowAtPoint(point) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        UIView.animateWithDuration(0.2, animations: { () -> Void in
          
          self.tableView.visibleCells.forEach({ (visibleCell) -> () in
            var frame = visibleCell.imageView!.frame
            frame.origin.x = (visibleCell == cell) ? 15.0 : -frame.width/2
            visibleCell.imageView!.frame = frame
          })
          
          }, completion: { (finished) -> Void in
            if let previewIndex = self.previewMemberIndex where previewIndex != indexPath.row {
              self.previewMemberIndex = indexPath.row
              // FIXME: Check for indexpath.row out of bounds
              self.firePreviewMember(self.data[indexPath.row])
            }
        })
      }
    case .Ended:
      fallthrough
    case .Cancelled:
      fallthrough
    case .Failed:
      fallthrough
    case .Recognized:
      UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
        (self.tableView as! TransparentTableView).backgroundBlurView.effect = UIBlurEffect(style: .ExtraLight)
        }, completion: { (finished) -> Void in
          self.previewMemberIndex = nil
          self.firePreviewMember(nil)
          
          UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.tableView.visibleCells.forEach({ (visibleCell) -> () in
              visibleCell.alpha = 1.0
              // Return all cell contents to full opacity
              visibleCell.contentView.subviews.forEach({ $0.alpha = 1.0 })
              visibleCell.textLabel?.alpha = 1.0
              
              var frame = visibleCell.imageView!.frame
              frame.origin.x = 15.0
              visibleCell.imageView!.frame = frame
            })
            
            self.tableView.visibleCells.forEach({ $0.alpha = 1.0 })
            }, completion: nil)
      })
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      // TODO: Remove fake rows
      return data.count * 3
    default:
      fatalError("Unexpected number of sections")
    }
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let controlCell = tableView.dequeueReusableCellWithIdentifier("ControlsCell", forIndexPath: indexPath) as! LocationControlTableViewCell
      if controlCell.userTrackingButton.mapView != self.mapView {
        controlCell.userTrackingButton.mapView = self.mapView
      }
      return controlCell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell", forIndexPath: indexPath) as! MemberTableViewCell
    
    // TODO: Remove fake rows
    cell.textLabel!.text = self.data[indexPath.row % 3].name
    cell.imageView!.image = UIImage(named: self.data[indexPath.row % 3].name)
    
    return cell
  }
  
  func firePreviewMember(member: Member?) {
    for listener in previewMemberListeners {
      listener.previewMember(member)
    }
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
