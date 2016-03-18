//
//  MembersDrawViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 10/03/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import Firebase

protocol PreviewMemberListener: NSObjectProtocol {
  //  func previewMember(member: Member?) //, atZoomLevel: MKZoomScale)
  func previewMember(member: Team.Member?) //, atZoomLevel: MKZoomScale)
}

extension UIImage {
  class func imageWithCenteredText(text: NSString, withSize size: CGSize, var withMaxFont font: UIFont) -> UIImage {
    var fontSize = text.sizeWithAttributes([NSFontAttributeName : font])
    while (fontSize.width * 1.1 > size.width) {
      font = font.fontWithSize(font.pointSize - 1)
      fontSize = text.sizeWithAttributes([NSFontAttributeName : font])
    }
    print(font.pointSize)
    
    let point = CGPointMake(size.width/2 - fontSize.width/2, size.height/2 - fontSize.height/2)
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0)
//    UIColor(red: 129/255, green: 208/255, blue: 131/255, alpha: 1.0).setFill()
    UIColor(hue: 122/360, saturation: 100/100, brightness: 25/100, alpha: 1.0).setFill()
    UIRectFill(CGRectMake(0, 0, size.width, size.height))
    
    let rect = CGRectMake(point.x, point.y, size.width, size.height)
    UIColor.whiteColor().set()
    
    let attr = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
    text.drawInRect(rect, withAttributes: attr)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    
//    UIGraphicsBeginImageContextWithOptions(size, true, 0.0) //mainScreen.scale?
//    self.drawInRect(CGRectMake(0, 0, size.width, size.height))
//    
//    let image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
    
    return image
  }
}


class MembersDrawViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  private var previewMemberListeners: [PreviewMemberListener] = []
  
  var ref: Firebase? {
    willSet {
      self.ref?.removeAllObservers()
    }
    didSet {
      self.ref?.observeEventType(.ChildAdded, withBlock: memberAdded)
      self.ref?.observeEventType(.ChildRemoved, withBlock: memberRemoved)
    }
  }
  
  @IBOutlet var searchView: UIView!
  @IBOutlet var collectionView: UICollectionView!
  
  var team: Team? {
    didSet {
      guard let team = self.team else {
        self.ref = nil
        self.collectionView.deleteSections(NSIndexSet(index: 1))
//        self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)])
        return
      }
      self.ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/teams/\(team.id)/members")
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - UICollectionViewDataSource
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 3
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return self.team?.members.count ?? 0
    case 2:
      return 1
      
    default:
      fatalError("Unrecongised number of sections")
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let identifier = indexPath.section == 2 ? "addMemberCell" : "memberCell"
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
    
    if let cell = cell as? MemberCollectionViewCell {
      if indexPath.section == 0 {
        
        cell.imageView.image = UIImage.imageWithCenteredText("JW", withSize: cell.imageView.bounds.size, withMaxFont: UIFont.systemFontOfSize(20))
//        cell.imageView.image = UIImage(named: "John")?.imageWithCenteredText("HE", withFont: UIFont(name: "Futura-Medium", size: 30)!)
      } else {
        cell.imageView.image = UIImage(named: self.team!.members[indexPath.row].username)
      }
    }
//    else if let cell = cell as? AddMemberCollectionViewCell {
//      if indexPath.section == 0 {
//        cell.imageView.image = UIImage(named: "Contact")
//      } else {
//        cell.imageView.image = UIImage(named: self.names[indexPath.row])
//      }
//    }
    
    cell.layer.shouldRasterize = true;
    cell.layer.rasterizationScale = UIScreen.mainScreen().scale;
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "memberFooter", forIndexPath: indexPath)
    footer.hidden = indexPath.section != 0
    return footer
  }
  
  // MARK: - UICollectionViewDelegate
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var size = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    
    if indexPath.section == 2 {
      size.width = 36
    }
    
    return size
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if section == 0 {
      return (collectionViewLayout as! UICollectionViewFlowLayout).footerReferenceSize
    } else {
      return CGSizeZero
    }
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 {
      self.firePreviewMember(self.team!.members[indexPath.row])
    }
    if indexPath.section == 2 {
      print(self.parentViewController)
      self.parentViewController?.performSegueWithIdentifier("AddMember", sender: self)
    }
  }
  
  
  // MARK: - preview listener methods
  
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
  
  
  // MARK: - Firebase handlers
  
  func memberAdded(snap: FDataSnapshot!) {
    let member = Team.Member(username: snap.key)
//    print("member added: \(member.username)")
    
    snap.ref.root.childByAppendingPath("users/\(member.username)/name").observeSingleEventOfType(.Value) { (userSnap: FDataSnapshot!) -> Void in
      guard let fullName = userSnap.value as? String else {
        print("WARNING: User \(member.username) does not have an associated name")
        return
      }
      member.name = fullName
      
      // 3: If all above successful then add the member to the table view
      self.team!.members.append(member)
      self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: self.team!.members.count - 1, inSection: 1)])
      
    }
  }
  
  func memberRemoved(snap: FDataSnapshot!) {
    let username = snap.key
    
    if let index = self.team?.members.indexOf({ $0.username == username }) {
      self.team!.members.removeAtIndex(index)
      self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)])
    }
  }


  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
