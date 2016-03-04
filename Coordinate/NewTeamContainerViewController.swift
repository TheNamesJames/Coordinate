//
//  NewTeamContainerViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 02/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class NewTeamContainerViewController: UIViewController {
  
  @IBOutlet var backBarButton: UIBarButtonItem!
  @IBOutlet var nextBarButton: UIBarButtonItem!
  @IBOutlet var doneBarButton: UIBarButtonItem!
  
  var pageViewController: UIPageViewController!
  
  private let scenes: [NewTeamViewController.Scene] = [.TeamName, .TeamID, .Username]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func backPressed(sender: UIBarButtonItem) {
    let current = self.pageViewController.viewControllers!.first!
    
    if let prev = self.pageViewController(self.pageViewController, viewControllerBeforeViewController: current) {
      self.pageViewController.setViewControllers([prev], direction: .Reverse, animated: true) { (done) -> Void in
        //        prev?.becomeFirstResponder()
      }
      
      // Ensure 'next' button is shown instead of 'done'
      if self.navigationItem.rightBarButtonItem != self.nextBarButton {
        self.navigationItem.setRightBarButtonItem(self.nextBarButton, animated: true)
      }
      
      // If navigating to first page, hide the back button
      if (prev as! NewTeamViewController).scene == self.scenes.first {
        self.navigationItem.setLeftBarButtonItem(nil, animated: false)
      }
    }
  }
  
  @IBAction func nextPressed(sender: UIBarButtonItem) {
    // TODO: Validate text (using newTeamDelegate methods??)
    
    let current = self.pageViewController.viewControllers!.first!
    
    if let next = self.pageViewController(self.pageViewController, viewControllerAfterViewController: current) {
      self.navigationItem.setLeftBarButtonItem(self.backBarButton, animated: true)
      self.pageViewController.setViewControllers([next], direction: .Forward, animated: true) { (done) -> Void in
        //        next?.becomeFirstResponder()
      }
      
      // Ensure back button shown
      if self.navigationItem.leftBarButtonItem == self.backBarButton {
        self.navigationItem.setLeftBarButtonItem(self.backBarButton, animated: true)
      }
      
      // If navigating to last page, update the 'next' button
      if (next as! NewTeamViewController).scene == self.scenes.last {
        self.navigationItem.setRightBarButtonItem(self.doneBarButton, animated: true)
      }
    } else {
      //      self.navigationItem.setRightBarButtonItem(done, animated: true)
    }
  }
  
  @IBAction func donePressed(sender: UIBarButtonItem) {
    self.performSegueWithIdentifier("ShowAllMembersSegue", sender: sender)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "EmbedNewTeamSegue" {
      self.pageViewController = segue.destinationViewController as! UIPageViewController
      
      self.pageViewController.dataSource = self
      self.pageViewController.delegate = self
      let initialViewController = self.newTeamViewControllerForSceneIndex(0)
      self.pageViewController.setViewControllers([initialViewController], direction: .Forward, animated: false, completion: { (completed) -> Void in
//        initialViewController.becomeFirstResponder()
      })
    }
  }
  
}

extension NewTeamContainerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  
  func newTeamViewControllerForSceneIndex(index: Int) -> NewTeamViewController {
    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("NewTeamViewController") as! NewTeamViewController
    
    vc.scene = self.scenes[index]
    
    return vc
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    let viewController = viewController as! NewTeamViewController
    if let index = self.scenes.indexOf(viewController.scene) {
      if index > 0 {
        return newTeamViewControllerForSceneIndex(index - 1)
      }
    }
    
    // Either first page or not found..
    return nil
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    let viewController = viewController as! NewTeamViewController
    if let index = self.scenes.indexOf(viewController.scene) {
      if index < self.scenes.count - 1 {
        return newTeamViewControllerForSceneIndex(index + 1)
      }
    }
    
    // Either last page or not found..
    return nil
  }
  
//  TODO: Make a custom page control status (progress indicator view under navbar?)
//  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//    return self.scenes.count
//  }
//  
//  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//    if let current = (pageViewController.viewControllers?.first as? NewTeamViewController)?.scene{
//      print("current: \(current)")
//      return self.scenes.indexOf(current)!
//    }
//    return 0
//  }
}
