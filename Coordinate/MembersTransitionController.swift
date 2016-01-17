//
//  MembersTransitionController.swift
//  Coordinate
//
//  Created by James Wilkinson on 17/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class MembersTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
  
  private let fadeDuration = 0.1
  private let slideDuration = 0.4
  let presenting: Bool
  
  init(presenting: Bool) {
    self.presenting = presenting
    super.init()
  }
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return self.slideDuration + self.fadeDuration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    if presenting {
      presentTransition(transitionContext)
    } else {
      dismissTransition(transitionContext)
    }
  }
  
  private func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
    let membersVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! MembersViewController
    
    membersVC.blurView.effect = nil
    
    let tableViewFrame = membersVC.tableView.frame
    membersVC.tableView.transform = CGAffineTransformMakeTranslation(0.0, -tableViewFrame.origin.y - tableViewFrame.size.height)
    
    membersVC.navBar.alpha = 0.0
    
    transitionContext.containerView()?.addSubview(membersVC.view)
    
    UIView.animateWithDuration(self.fadeDuration) { () -> Void in
      membersVC.navBar.alpha = 1.0
    }
    
    UIView.animateWithDuration(self.slideDuration, delay: self.fadeDuration, options: .CurveEaseOut, animations: { () -> Void in
      membersVC.tableView.transform = CGAffineTransformIdentity
      membersVC.blurView.effect = UIBlurEffect(style: .ExtraLight)
      }, completion: { (finished) -> Void in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    })
  }
  
  private func dismissTransition(transitionContext: UIViewControllerContextTransitioning) {
    let membersVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! MembersViewController
    
    UIView.animateWithDuration(self.slideDuration, delay: 0.0, options: .CurveEaseIn, animations: { () -> Void in
      let tableViewFrame = membersVC.tableView.frame
      membersVC.tableView.transform = CGAffineTransformMakeTranslation(0.0, -tableViewFrame.origin.y - tableViewFrame.size.height)
      membersVC.blurView.effect = nil
      }, completion: nil)
    
    UIView.animateWithDuration(self.fadeDuration, delay: self.slideDuration, options: .CurveEaseOut, animations: { () -> Void in
      membersVC.navBar.alpha = 0.0
      }, completion: { (finished) -> Void in
        membersVC.view.removeFromSuperview()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    })
  }
  
}
