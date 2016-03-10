//
//  TransitionManager.swift
//  Coordinate
//
//  Created by James Wilkinson on 08/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class TeamTransition: NSObject, UIViewControllerAnimatedTransitioning {
  
  let presenting: Bool
  var cell: UITableViewCell? // TODO: use selected indexPath instead?
  
  override init() {
    self.presenting = true
  }
  
  init(presentFromCell cell: UITableViewCell) {
    self.presenting = true
    self.cell = cell
    super.init()
  }
  
  init(dismissToCell cell: UITableViewCell?) {
    self.presenting = false
    self.cell = cell
    super.init()
  }
  
  // MARK: UIViewControllerAnimatedTransitioning protocol methods
  
  // animate a change from one viewcontroller to another
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    // get reference to our fromView, toView and the container view that we should perform the transition in
    let container = transitionContext.containerView()!
    let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
    // set up from 2D transforms that we'll use in the animation
    let offScreenBottom = CGAffineTransformMakeTranslation(0, container.frame.height)
    let offScreenTop = CGAffineTransformMakeTranslation(0, -container.frame.height)
    
    // start the toView to the right of the screen
    toView.transform = self.presenting ? offScreenBottom : offScreenTop
    
    // add the both views to our view controller
    container.addSubview(fromView)
    if presenting {
      container.insertSubview(toView, aboveSubview: fromView)
    } else {
      container.insertSubview(toView, belowSubview: fromView)
    }
    
    // get the duration of the animation
    // DON'T just type '0.5s' -- the reason why won't make sense until the next post
    // but for now it's important to just follow this approach
    let duration = self.transitionDuration(transitionContext)
    
    // perform the animation!
    if let cell = self.cell where presenting == true {
      let tableView = fromView as! UITableView
      let rect = tableView.rectForRowAtIndexPath(tableView.indexPathForCell(cell)!)
      
      let midpoint = CGAffineTransformMakeTranslation(0, rect.origin.y + rect.height)
      let negativeMidpoint = CGAffineTransformMakeTranslation(0, -(rect.origin.y + rect.height))
      let toBGColour = toView.backgroundColor
      toView.backgroundColor = UIColor.clearColor()
      
//      let navbarSnap = toVC.navigationController!.navigationBar.snapshotViewAfterScreenUpdates(false)
      UIGraphicsBeginImageContextWithOptions(toVC.navigationController!.navigationBar.bounds.size, false, 0)
      
      toVC.navigationController!.navigationBar.drawViewHierarchyInRect(toVC.navigationController!.navigationBar.bounds, afterScreenUpdates:true)
      
      let navbarSnap = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
      
      UIGraphicsEndImageContext()
      
      navbarSnap.frame = toVC.navigationController!.navigationBar.frame
      toVC.navigationController!.navigationBar.alpha = 0
      container.addSubview(navbarSnap)
      toVC.navigationController!.navigationBar.transform = midpoint
      
      
      UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeCubic, animations: { () -> Void in
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
          toView.transform = midpoint
        })
        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
          fromView.transform = negativeMidpoint
          navbarSnap.transform = negativeMidpoint
          toVC.navigationController!.navigationBar.alpha = 1
          toVC.navigationController!.navigationBar.transform = CGAffineTransformIdentity
          toView.transform = CGAffineTransformIdentity
        })
        }, completion: { (finished) -> Void in
          // tell our transitionContext object that we've finished animating
          transitionContext.completeTransition(true)
          toView.backgroundColor = toBGColour
      })
    } else {
      let table = toView as! UITableView
      let midpoint = CGAffineTransformMakeTranslation(0, CGFloat(table.numberOfRowsInSection(0)) * table.rowHeight)
      let negativeMidpoint = CGAffineTransformMakeTranslation(0, CGFloat(table.numberOfRowsInSection(0)) * -table.rowHeight)
      let fromBGColour = fromView.backgroundColor
      fromView.backgroundColor = UIColor.clearColor()
      
      toView.transform = negativeMidpoint
      
      UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeCubic, animations: { () -> Void in
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
          fromView.transform = midpoint
          toView.transform = CGAffineTransformIdentity
        })
        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
          fromView.transform = offScreenBottom
          
//          navbarSnap.transform = negativeMidpoint
//          toVC.navigationController!.navigationBar.alpha = 1
//          toVC.navigationController!.navigationBar.transform = CGAffineTransformIdentity
        })
        }, completion: { (finished) -> Void in
          // tell our transitionContext object that we've finished animating
          transitionContext.completeTransition(true)
          fromView.backgroundColor = fromBGColour
//          toView.backgroundColor = toBGColour
      })
      
//      UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: {
//        
//        fromView.transform = self.presenting ? offScreenTop : offScreenBottom
//        toView.transform = CGAffineTransformIdentity
//        
//        }, completion: { finished in
//          
//          // tell our transitionContext object that we've finished animating
//          transitionContext.completeTransition(true)
//          
//      })
    }
  }
  
  // return how many seconds the transiton animation will take
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.95
  }
  
  //  // MARK: UIViewControllerTransitioningDelegate protocol methods
  //
  //  // return the animataor when presenting a viewcontroller
  //  // remmeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
  //  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
  //    return self
  //  }
  //
  //  // return the animator used when dismissing from a viewcontroller
  //  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
  //    return self
  //  }
}
