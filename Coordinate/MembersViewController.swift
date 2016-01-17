//
//  OccupantsViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 14/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var navBar: UINavigationBar!
  @IBOutlet weak var navItem: UINavigationItem!
  
  var data: [Member] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let blurEffect = UIBlurEffect(style: .ExtraLight)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = tableView.frame
    tableView.backgroundColor = UIColor.clearColor()
    tableView.backgroundView = blurView
    tableView.separatorStyle = .None
//    tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func doneTapped(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func memberCellLongTapped(sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .Possible: break
    case .Began:
      let point = sender.locationInView(self.tableView)
      if let indexPath = self.tableView.indexPathForRowAtPoint(point) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
          let effectView = self.tableView.backgroundView as! UIVisualEffectView
          effectView.effect = UIBlurEffect(style: .Light)
          self.navItem.title = cell.textLabel?.text
          }, completion: { (finished) -> Void in
            UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//              self.tableView.backgroundView!.backgroundColor = UIColor.clearColor()
              self.tableView.backgroundView!.alpha = 0.4
              for visibleCell in self.tableView.visibleCells {
                if visibleCell != cell {
                  visibleCell.alpha = 0.0
                } else {
                  visibleCell.alpha = 1.0
                }
              }
              }, completion: nil)
        })
      }
    case .Changed:
      let point = sender.locationInView(self.tableView)
      if let indexPath = self.tableView.indexPathForRowAtPoint(point) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        self.navItem.title = cell.textLabel?.text
        UIView.animateWithDuration(0.2, animations: { () -> Void in
          for visibleCell in self.tableView.visibleCells {
            if visibleCell != cell {
              visibleCell.alpha = 0.0
            } else {
              visibleCell.alpha = 1.0
            }
          }
          }, completion: { (finished) -> Void in
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
        let effectView = self.tableView.backgroundView as! UIVisualEffectView
        effectView.effect = UIBlurEffect(style: .ExtraLight)
        self.navItem.title = "Members"
        }, completion: { (finished) -> Void in
          UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//            self.tableView.backgroundView!.backgroundColor = nil
            self.tableView.backgroundView!.alpha = 1.0
            
            self.tableView.visibleCells.forEach({ (cell) -> () in
              cell.alpha = 1.0
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
