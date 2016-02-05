//
//  SimulatorViewController.swift
//  Coordinate
//
//  Created by James Wilkinson on 29/01/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit
import MapKit
import Parse

class SimulatorViewController: UIViewController {
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var hintLabel: UILabel!
  @IBOutlet weak var centerPin: UIImageView!
  
  @IBOutlet var loginSection: [UIView]!
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet var simulatorSection: [UIView]!
  
  @IBAction func loginPressed(sender: AnyObject) {
    if let user = usernameTextField.text where !user.isEmpty,
      let pass = passwordTextField.text where !pass.isEmpty {
        PFUser.logInWithUsernameInBackground(user, password: pass, block: { (user, error) -> Void in
          if let error = error {
            print(error)
            self.hintLabel.text = "Incorrect.. Try again"
          } else {
            print("success")
          }
          UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.loginSection.forEach({ (view) -> () in
              view.alpha = 0.3
              view.userInteractionEnabled = false
            })
            self.simulatorSection.forEach({ (view) -> () in
              view.alpha = 1.0
              view.userInteractionEnabled = true
            })
          })
        })
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
//    self.simulatorSection.forEach { (view) -> () in
//      view.alpha = 0.4
//      view.userInteractionEnabled = false
//    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func panned(sender: AnyObject) {
    
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

extension SimulatorViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.05, animations: { () -> Void in
        self.centerPin.alpha = 0.7
      })
    } else {
      self.centerPin.alpha = 0.7
    }
  }
  
  func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.05, animations: { () -> Void in
        self.centerPin.alpha = 1
      })
    } else {
      self.centerPin.alpha = 1
    }
    
    let newCenter = mapView.region.center
    print(newCenter)
    var dataDictionary: [String:AnyObject] = [:]
    // TODO: Add name/id of user
    dataDictionary["latitude"] = newCenter.latitude
    dataDictionary["longitude"] = newCenter.longitude
    
    if NSJSONSerialization.isValidJSONObject(dataDictionary) {
      do {
        let data = try NSJSONSerialization.dataWithJSONObject(dataDictionary, options: NSJSONWritingOptions.init(rawValue: 0))
        if let message = NSString(data: data, encoding: NSUTF8StringEncoding) {
          let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
          delegate.pubnubClient?.publish(message, toChannel: delegate.channel, withCompletion: { (status) -> Void in
            print(status)
          })
        }
        
      } catch let error {
        print(error)
      }
    }
  }
}
