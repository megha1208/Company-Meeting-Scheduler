//
//  Meeting.swift
//  CompanyMeetingScheduler
//
//  Created by Megha Johari on 5/9/19.
//  Copyright © 2019 Megha Johari. All rights reserved.
//

import Foundation

class Meeting: NSObject, NSCoding {
    
    var startTime: String
    var endTime: String
    var meetingDesc: String
    var participants: [String]
    
    init(startTime: String, endTime: String, meetingDesc: String, participants: [String]) {
        self.startTime = startTime
        self.endTime = endTime
        self.meetingDesc = meetingDesc
        self.participants = participants
    }
    
    convenience init?(dictionary: [String: Any]) {
        guard let startTime = dictionary["start_time"],
            let endTime = dictionary["end_time"],
            let meetingDesc = dictionary["description"],
            let participants = dictionary["participants"] else {
                return nil
        }
        
        self.init(startTime: startTime as! String, endTime: endTime as! String, meetingDesc: meetingDesc as! String, participants: participants as! [String])
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.startTime = aDecoder.decodeObject(forKey: "start_time") as! String
        self.endTime = aDecoder.decodeObject(forKey: "end_time") as! String
        self.meetingDesc = aDecoder.decodeObject(forKey: "description") as! String
        self.participants = aDecoder.decodeObject(forKey: "participants") as! [String]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: "start_time")
        aCoder.encode(endTime, forKey: "end_time")
        aCoder.encode(meetingDesc, forKey: "description")
        aCoder.encode(participants, forKey: "participants")
    }
    
//    required  init(coder aDecoder: NSCoder) {
//        let startTime = aDecoder.decodeObject(forKey: "start_time") as! String
//        let endTime = aDecoder.decodeObject(forKey: "end_time") as! String
//        let description = aDecoder.decodeObject(forKey: "description") as! String
//        let participants = aDecoder.decodeObject(forKey: "participants") as! [String]
//        self.init(startTime: startTime, endTime: endTime, description: description, participants: participants)
//    }
//
//    func encode(with aCoder: NSCoder){
//        aCoder.encode(startTime, forKey: "start_time")
//        aCoder.encode(endTime, forKey: "scoend_timere")
//        aCoder.encode(description, forKey: "description")
//        aCoder.encode(participants, forKey: "participants")
//    }
    
}


struct defaultsKeys {
    static let keyMeetingArray = "meeting"
    static let keyURLString = "urlString"
}
