//
//  TransitionManagerController.swift
//  Coordinate
//
//  Created by James Wilkinson on 08/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class TransitionManagerController: NSObject, UINavigationControllerDelegate {
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if let fromVC = fromVC as? MembershipTableViewController where operation == .Push {
      let cell = fromVC.tableView.cellForRowAtIndexPath(fromVC.tableView.indexPathForSelectedRow!)
      
      return TeamTransition(presentFromCell: cell!)
    }
    
    if let _ = toVC as? MembershipTableViewController where operation == .Pop {
      // Replace with selected Team's cell?
      return TeamTransition(dismissToCell: nil)
    }
    
    return nil
  }
}
