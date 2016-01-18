//
//  OccupantsViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 14/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var navBar: UINavigationBar!
  @IBOutlet weak var navItem: UINavigationItem!
  
  var data: [Member] = []
  var delegate: MembersViewControllerDelegate? = nil
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.transitioningDelegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    tableView.backgroundColor = UIColor.clearColor()
    tableView.separatorStyle = .None
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func doneTapped(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  private var previewMemberIndex: Int? = nil
  
  @IBAction func memberCellLongTapped(sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .Possible: break
    case .Began:
      let point = sender.locationInView(self.tableView)
      if let indexPath = self.tableView.indexPathForRowAtPoint(point) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
          self.blurView.effect = nil
          self.navItem.title = cell.textLabel?.text

          self.tableView.visibleCells.forEach({ (visibleCell) -> () in
            // Make all cell contents transparent except for imageView
            visibleCell.contentView.subviews.filter({ !(($0 is UIImageView) || ($0 is UIVisualEffectView)) }).forEach({ $0.alpha = 0.0 })
            
            var frame = visibleCell.imageView!.frame
            frame.origin.x = (visibleCell == cell) ? 15.0 : -frame.width/2
            visibleCell.imageView!.frame = frame
          })
          
          }, completion: { (finished) -> Void in
            self.previewMemberIndex = indexPath.row
            self.delegate?.previewMemberLocation(self.data[indexPath.row])
        })
      }
    case .Changed:
      let point = sender.locationInView(self.tableView)
      if let indexPath = self.tableView.indexPathForRowAtPoint(point) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        self.navItem.title = cell.textLabel?.text
        UIView.animateWithDuration(0.2, animations: { () -> Void in
          
          self.tableView.visibleCells.forEach({ (visibleCell) -> () in
            var frame = visibleCell.imageView!.frame
            frame.origin.x = (visibleCell == cell) ? 15.0 : -frame.width/2
            visibleCell.imageView!.frame = frame
          })
          
          }, completion: { (finished) -> Void in
            if let previewIndex = self.previewMemberIndex where previewIndex != indexPath.row {
              self.previewMemberIndex = indexPath.row
              self.delegate?.previewMemberLocation(self.data[indexPath.row])
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
        self.blurView.effect = UIBlurEffect(style: .ExtraLight)
        self.navItem.title = "Members"
        }, completion: { (finished) -> Void in
          self.previewMemberIndex = nil
          self.delegate?.previewMemberLocation(nil)
          
          UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.tableView.visibleCells.forEach({ (visibleCell) -> () in
              visibleCell.alpha = 1.0
              // Return all cell contents to full opacity
              visibleCell.contentView.subviews.forEach({ $0.alpha = 1.0 })
              
              var frame = visibleCell.imageView!.frame
              frame.origin.x = 15.0
              visibleCell.imageView!.frame = frame
            })
            
            self.tableView.visibleCells.forEach({ $0.alpha = 1.0 })
            }, completion: nil)
      })
    }
  }
  
  // MARK: UINavigationBarDelegate
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
  
  // MARK: UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell")!
    
    cell.textLabel?.text = data[indexPath.row].name
    
    let itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale);
    let imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    cell.imageView!.image!.drawInRect(imageRect);
    cell.imageView!.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.imageView!.backgroundColor = UIColor.whiteColor()
    cell.imageView!.layer.cornerRadius = itemSize.width/2
    
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}

extension MembersViewController: UIViewControllerTransitioningDelegate {
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return MembersTransitionController(presenting: true)
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return MembersTransitionController(presenting: false)
  }
}

protocol MembersViewControllerDelegate {
  func previewMemberLocation(member: Member?) //, atZoomLevel: MKZoomScale)
}
