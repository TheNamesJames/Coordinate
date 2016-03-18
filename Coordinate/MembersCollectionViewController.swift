//
//  MembersCollectionViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 10/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "memberCell"



class MembersCollectionViewController: UICollectionViewController {
  
  let ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/")
  
  var previewMemberListeners: [PreviewMemberListener] = []
  var team: Team!
  
  func addPreviewMemberListener(listener: PreviewMemberListener) {
    self.previewMemberListeners.append(listener)
  }
  
  func removePreviewMemberListener(listener: PreviewMemberListener) {
    if let index = self.previewMemberListeners.indexOf({ $0 === listener }) {
      self.previewMemberListeners.removeAtIndex(index)
    }
  }

  func firePreviewMember(member: Team.Member?) {
    for listener in previewMemberListeners {
      listener.previewMember(member)
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
//    self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // Do any additional setup after loading the view.

    // Show a list of members
    // 1.1: As members are added to team..
    ref.childByAppendingPath("teams/\(self.team.id)/members").observeEventType(.ChildAdded) { (memberSnap: FDataSnapshot!) -> Void in
      let username = memberSnap.key
      let member = Team.Member(username: username)
      
      // 2.1: Get details for that username
      self.ref.childByAppendingPath("users/\(username)/name").observeSingleEventOfType(.Value, withBlock: { (userSnap: FDataSnapshot!) -> Void in
        guard let fullName = userSnap.value as? String else {
          print("WARNING: User \(username) does not have an associated name")
          return
        }
        member.name = fullName
        
        // 3: If all above successful then add the member to the table view
        self.team.members.append(member)
        self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forRow: self.team.members.count - 1, inSection: 1)])
      })
    }
    // 1.2: As members are removed from team..
    ref.childByAppendingPath("teams/\(self.team.id)/members").observeEventType(.ChildRemoved) { (memberSnap: FDataSnapshot!) -> Void in
      let username = memberSnap.key
      
      if let index = self.team.members.indexOf({ $0.username == username }) {
        self.team.members.removeAtIndex(index)
        self.collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)])
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 2
  }
  
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return section == 0 ? 1 : self.team.members.count * 3
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if indexPath.section == 0 {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("locateCell", forIndexPath: indexPath) as! LocateCollectionViewCell
      cell.label.text = "Locate"
      cell.layer.shouldRasterize = true;
      cell.layer.rasterizationScale = UIScreen.mainScreen().scale;
      return cell
    }
    
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemberCollectionViewCell
    
    // Configure the cell
    let username = self.team.members[indexPath.row].username
    let image = UIImage(named: username)
    cell.imageView.image = image
    
    cell.layer.shouldRasterize = true;
    cell.layer.rasterizationScale = UIScreen.mainScreen().scale;
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TeamHeader", forIndexPath: indexPath)
    return header
  }
  
  // MARK: UICollectionViewDelegate
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    self.firePreviewMember(self.team.members[indexPath.row])
  }
  
  /*
  // Uncomment this method to specify if the specified item should be highlighted during tracking
  override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
  return true
  }
  */
  

  // Uncomment this method to specify if the specified item should be selected
  override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
  return true
  }
  
  /*
  // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
  override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
  return false
  }
  
  override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
  return false
  }
  
  override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
  
  }
  */
  
}
