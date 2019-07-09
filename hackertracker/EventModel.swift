//
//  File.swift
//  hackertracker
//
//  Created by Christopher Mays on 6/18/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Foundation

struct HTEventModel : Codable {
    var id : Int
    var conferenceName : String
    var description : String
    var beginDate : Date
    var begin : Date
    var endDate : Date
    var includes : String
    var links : String
    var title : String
    var location : HTLocationModel
    var speakers : [HTSpeaker]
    var type : HTEventType
}

extension HTEventModel : Document {
    init?(dictionary: [String : Any]) {
        let dfu = DateFormatterUtility.shared
        let tmp_date = "2019-01-01T00:00:00.000-0000"
        let id = dictionary["id"] as? Int ?? 0
        let beginDate = dfu.iso8601Formatter.date(from: dictionary["begin"] as? String ?? tmp_date)!
        let begin = dictionary["begin_timestamp"] as? Date ?? dfu.iso8601Formatter.date(from: tmp_date)!
        let conferenceName = dictionary["conference"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        let endDate =  dfu.iso8601Formatter.date(from: dictionary["end"] as? String ?? tmp_date)!
        let includes = dictionary["includes"] as? String ?? ""
        let link = dictionary["link"] as? String ?? ""
        let title = dictionary["title"] as? String ?? ""
        
        var location : HTLocationModel?;
        if let locationValues = dictionary["location"] as? Dictionary<String, Any>  {
            location = HTLocationModel(dictionary: locationValues)
        }
        
        var speakers : [HTSpeaker]?;
        if let speakersValues = dictionary["speakers"] as? Array<Any>  {
            
            speakers = speakersValues.compactMap { (element) -> HTSpeaker? in
                if let element = element as? Dictionary<String, Any>, let speaker = HTSpeaker(dictionary: element) {
                    return speaker
                }
                
                return nil
            }
        }
        
        var type : HTEventType?;
        if let typeValues = dictionary["type"] as? Dictionary<String, Any>  {
            type = HTEventType(dictionary: typeValues)
        }
        
        guard  let typeVal = type, let speakersVal = speakers, let locationVal = location else {
            return nil;
        }
        
        self.init(id: id, conferenceName: conferenceName, description: description, beginDate: beginDate, begin: begin, endDate: endDate, includes: includes, links: link, title: title, location: locationVal, speakers: speakersVal, type: typeVal)
    }
}

struct HTLocationModel : Codable {
    var id : Int
    var conferenceName : String
    var name : String
}

extension HTLocationModel : Document {
    init?(dictionary: [String : Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let conferenceName = dictionary["conference"] as? String ?? ""
        let name = dictionary["name"] as? String ?? ""

        self.init(id: id, conferenceName: conferenceName, name: name)
    }
}

struct HTSpeaker : Codable {
    var id : Int
    var conferenceName : String
    var description : String
    var link : String
    var name : String
    var title : String
    var twitter : String
    var events: [HTEventModel]
}

extension HTSpeaker : Document {
    init?(dictionary: [String : Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let conferenceName = dictionary["conference"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        let link = dictionary["link"] as? String ?? ""
        let name = dictionary["name"] as? String ?? ""
        let title = dictionary["title"] as? String ?? ""
        let twitter = dictionary["twitter"] as? String ?? ""

        var events : [HTEventModel] = []
        if let eventsValues = dictionary["events"] as? Array<Any>  {
            
            events = eventsValues.compactMap { (element) -> HTEventModel? in
                if let element = element as? Dictionary<String, Any>, let event = HTEventModel(dictionary: element) {
                    return event
                }
                
                return nil
            }
        }
        
        self.init(id: id, conferenceName: conferenceName, description: description, link: link, name: name, title: title, twitter: twitter, events: events)
    }
}

struct HTEventType : Codable {
    var id : Int
    var color : String
    var conferenceName : String
    var name : String
}

extension HTEventType : Document {
    init?(dictionary: [String : Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let color = dictionary["color"] as? String ?? ""
        let conferenceName = dictionary["conference"] as? String ?? ""
        let name = dictionary["name"] as? String ?? ""
        
        self.init(id: id, color: color, conferenceName: conferenceName, name: name)
    }
}
