//
//  Team.swift
//  Coordinate
//
//  Created by James Wilkinson on 26/02/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

typealias TeamResponse = (Team?, NSError?) -> Void
typealias TeamMembersResponse = ([Team.Member]!) -> Void


typealias ATeamResponse = (ATeam! -> Void)
//typealias ATeamMembersResponse = ([AMember]! -> Void)

class ATeam {
  let teamID: String
  var name: String?
  var currentMember: AMember
  var otherMembers: [AMember]?
  
  let teamNameRef: Firebase
  let teamMembersRef: Firebase
  
  private init(teamID: String, currentMember: AMember) {
    self.teamID         = teamID
    self.currentMember  = currentMember
    
    self.teamNameRef    = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/teams/\(teamID)/name")
    self.teamMembersRef = Firebase(url: "https://dazzling-heat-2970.firebaseio.com/teams/\(teamID)/members")
  }
}

class AMember {
  let username: String
  private(set) var forename: String?
  private(set) var surname: String?
  
  
  private init(username: String) {
    self.username = username
  }
}

class ATeamMember: AMember {
  private let teamID: String
  //  private var locationUpdates: [ALocationUpdate]?
  
  private init(username: String, teamID: String) {
    self.teamID = teamID
    super.init(username: username)
  }
  
//  func getLocationUpdatesWithBlock(doneBlock: (ALocationUpdate? -> Void)) {
//    
//  }
}

struct ALocationUpdate {
  let location: CLLocationCoordinate2D
  private(set) var timestamp: NSTimeInterval?
  
  private init(location: CLLocationCoordinate2D) {
    self.location = location
  }
}



let rootRef = Firebase(url:"https://dazzling-heat-2970.firebaseio.com")


class Team: CustomStringConvertible {
  let id: String
  var name: String?
  let currentMember: Member
  var members: [Member] // Sort members such that currentMember is last?
  
  init(id: String, currentMember: Member) {
    self.id = id
    self.currentMember = currentMember
    self.members = []
  }
  
  private init(id: String, name: String?, currentMember: Member, members: [Member]) {
    self.id = id
    self.name = name
    self.currentMember = currentMember
    self.members = members
  }
  
  var description: String {
    return "@\(id) > \(members)"
  }
  
  class Member: CustomStringConvertible {
    let username: String
    //  var id: String?
    var name: String?
    private(set) var lastLocationUpdate: LocationUpdate?
    
    init(username: String) {
      self.username = username
    }
    
    private init(username: String, name: String?, locationUpdate: LocationUpdate?) {
      self.username = username
      self.name = name
      self.lastLocationUpdate = locationUpdate
    }
    
    var description: String {
      return "/\(username)"
    }
  }
  
  struct LocationUpdate {
    let location: CLLocationCoordinate2D
    let timestamp: NSTimeInterval?
  }
  
//  class func teamForTeamID(teamID: String, withCallback callback: TeamResponse) {
//    ref.childByAppendingPath("teams/\(teamID)").observeSingleEventOfType(.Value) { (snap: FDataSnapshot!) -> Void in
//      guard snap.exists() else {
//        let description = ["description": "Team does not exist"]
//        callback(nil, NSError(domain: "TeamResponse", code: 54321, userInfo: description))
//        return
//      }
//      
//      let teamDict = snap.value as! NSDictionary
//      let team = Team(id: snap.key)
//      team.name = teamDict["name"] as! String?
//
//      
//      var members: [Member] = []
//      
//      snap.ref.childByAppendingPath("users").observeSingleEventOfType(.Value, withBlock: { (usersSnap: FDataSnapshot!) -> Void in
//        let users = usersSnap.value as! Dictionary<String, AnyObject>
//        for (username, user) in users {
//          let member = Member(username: username)
//          
//          let user = user as! Dictionary<String, AnyObject>
//          member.first = user["first"] as! String?
//          member.last = user["last"] as! String?
//          print("1:: \(member)")
//          
//          ref.childByAppendingPath("locations/\(teamID)/\(username)").queryLimitedToLast(1).observeSingleEventOfType(.Value, withBlock: { (locationSnap: FDataSnapshot!) -> Void in
//            if locationSnap.exists() {
//              let locationDetails = locationSnap.value as! Dictionary<String, AnyObject>
//              // FIXME: replace with vars and *then* check using `if`
//              if  let latitude = locationDetails["lat"] as? Double,
//                let longitude = locationDetails["lon"] as? Double {
//                  member.lastLocationUpdate = LocationUpdate(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), timestamp: nil)
//                  print("2:: \(member)")
//              }
//            }
//            members.append(member)
//          })
//          
//        }
//        team.members = members
//      })
//
//      callback(team, nil)
//    }
  
//    ref.childByAppendingPath("teams/\(teamID)/users").observeSingleEventOfType(.ChildAdded) { (snap: FDataSnapshot!) -> Void in
//      guard snap.exists() else {
//        let description = ["description": "Team does not exist"]
//        callback(nil, NSError(domain: "TeamResponse", code: 54321, userInfo: description))
//        return
//      }
//      let teamName = snap
//      print("\(snap.key) :: \(snap.value)")
//      
//      let description = ["description": "Team does not exist"]
//      callback(nil, NSError(domain: "TeamResponse", code: 54321, userInfo: description))
//    }
//  }
}
