//
//  OccupantsViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 14/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class OccupantsViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func doneTapped(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func occupantCellLongTapped(sender: UILongPressGestureRecognizer) {
    let point = sender.locationInView(self.tableView)
    if let indexPath = self.tableView.indexPathForRowAtPoint(point) {
      print(indexPath.row)
//      let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
      switch sender.state {
      case .Began:
        UIView.animateWithDuration(0.25, animations: { () -> Void in
          self.tableView.alpha = 0.0
        })
      case .Ended:
        UIView.animateWithDuration(0.25, animations: { () -> Void in
          self.tableView.alpha = 1.0
        })
        
      default: break
      }
    }
  }
  
  // MARK: UINavigationBarDelegate
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
  
  // MARK: UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("OccupantsCell")!
    
    cell.textLabel?.text = "Person \(indexPath.row)"
    
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
