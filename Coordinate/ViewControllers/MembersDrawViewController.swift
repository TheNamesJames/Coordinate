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
  func memberIconLongPressed(member: Team.Member)
  func locateSelf()
}

extension UIImage {
  class func imageWithCenteredText(text: String, withSize size: CGSize, withFontSizeRange range: ClosedInterval<CGFloat> = 9.0...20.0) -> UIImage {
    let limitedText: String
    if text.characters.count > 5 {
      limitedText = text.substringToIndex(text.startIndex.advancedBy(4)) + "…"
    } else {
      limitedText = text
    }
    
    var font = UIFont.systemFontOfSize(range.end)
    var fontSize = limitedText.sizeWithAttributes([NSFontAttributeName : font])
    while (fontSize.width * 1.1 > size.width) {
      font = font.fontWithSize(font.pointSize - 1.0)
      fontSize = limitedText.sizeWithAttributes([NSFontAttributeName : font])
    }
    
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

extension String {
  func initials() -> String {
    let x = self.componentsSeparatedByString(" ").map({ (partialName) -> String in
      String(partialName[partialName.startIndex])
    })
    return x.reduce("", combine: { $0 + $1 })
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
  
  var currentMember: Team.Member! {
    didSet {
      //self.collectionView.reloadSections(NSIndexSet(index: 0))
    }
  }
  var team: Team? {
    didSet {
      if let team = self.team {
        self.data = []
        self.ref = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/teams/\(team.id)/members")
      } else {
        self.ref = nil
        self.collectionView.deleteSections(NSIndexSet(index: 1))
        self.data = nil
//        self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)])
      }
      self.collectionView.reloadData()
    }
  }
  var data: [Team.Member]?
  
  
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
      return self.data?.count ?? 0
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
        if let member = self.currentMember {
          let initials = member.name?.initials().uppercaseString ?? "/\(member.username)"
          cell.imageView.image = UIImage.imageWithCenteredText(initials, withSize: cell.imageView.bounds.size)
        } else {
          cell.imageView.image = UIImage.imageWithCenteredText("", withSize: cell.imageView.bounds.size)
        }
//        cell.imageView.image = UIImage(named: "John")?.imageWithCenteredText("HE", withFont: UIFont(name: "Futura-Medium", size: 30)!)
      } else {
        let member = self.data![indexPath.row]
        let initials = member.name?.initials().uppercaseString ?? "/\(member.username)"
        
        cell.imageView.image = UIImage.imageWithCenteredText(initials, withSize: cell.imageView.bounds.size)
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
    if indexPath.section == 0 {
      self.fireLocateSelf()
    }
    if indexPath.section == 1 {
      self.firePreviewMember(self.data![indexPath.row])
    }
    if indexPath.section == 2 {
      self.parentViewController!.performSegueWithIdentifier("AddMember", sender: self)
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
  
  func fireMemberIconLongPressed(member: Team.Member) {
    for listener in previewMemberListeners {
      listener.memberIconLongPressed(member)
    }
  }

  func fireLocateSelf() {
    for listener in previewMemberListeners {
      listener.locateSelf()
    }
  }
  
  
  // MARK: - Firebase handlers
  
  func memberAdded(snap: FDataSnapshot!) {
    let username = snap.key
    
    // If member is not currentMember, add pin annotation
    if username != self.team?.currentMember.username {
      let member = Team.Member(username: snap.key)
      
      snap.ref.root.childByAppendingPath("users/\(member.username)/name").observeSingleEventOfType(.Value) { (userSnap: FDataSnapshot!) -> Void in
        guard let fullName = userSnap.value as? String else {
          print("WARNING: User \(member.username) does not have an associated name")
          return
        }
        member.name = fullName
        
        // 3: If all above successful then add the member to the table view
        self.data!.append(member)
        self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: self.data!.count - 1, inSection: 1)])
      }
    }
  }
  
  func memberRemoved(snap: FDataSnapshot!) {
    let username = snap.key
    
    if let index = self.data?.indexOf({ $0.username == username }) {
      self.data!.removeAtIndex(index)
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

extension MembersDrawViewController: UIGestureRecognizerDelegate {
  @IBAction func memberLongPressed(sender: UILongPressGestureRecognizer) {
    if sender.state == .Began {
      print("Begna")
      if let cellIndex = self.collectionView.indexPathForItemAtPoint(sender.locationInView(self.collectionView)) {
        if let member = self.data?[cellIndex.item] {
          self.fireMemberIconLongPressed(member)
        }
      }
    }
    if sender.state == .Ended {
      print("Ended")
    }
    if sender.state == .Failed {
      print("Faild")
    }
  }
  
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    let point = gestureRecognizer.locationInView(self.collectionView)
    if let index = self.collectionView.indexPathForItemAtPoint(point) {
      if index.section == 1 {
        return true
      }
    }
    
    return false
  }
}
