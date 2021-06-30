//
//  File.swift
//  hackertracker
//
//  Created by Christopher Mays on 6/18/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Bookmark: Codable {
    var id: String
    var value: Bool
}

extension Bookmark: Document {
    init?(dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? "0"
        let value = dictionary["value"] as? Bool ?? false

        self.init(id: id, value: value)
    }
}

struct HTEventModel: Codable {
    var id: Int
    var conferenceName: String
    var description: String
    var begin: Date
    var end: Date
    var includes: String
    var links: String
    var title: String
    var location: HTLocationModel
    var speakers: [HTSpeaker]
    var type: HTEventType
}

struct UserEventModel: Codable, Equatable {
    var event: HTEventModel
    var bookmark: Bookmark

    static func ==(lhs: UserEventModel, rhs: UserEventModel) -> Bool {
        if lhs.event.id == rhs.event.id && lhs.event.title == rhs.event.title && lhs.event.description == rhs.event.description {
            return true
        } else {
            return false
        }
    }
}

extension HTEventModel: Document {
    init?(dictionary: [String: Any]) {
        let dfu = DateFormatterUtility.shared
        let tmp_date = "2019-01-01T00:00:00.000-0000"
        let id = dictionary["id"] as? Int ?? 0
        var begin = dfu.iso8601Formatter.date(from: dictionary["begin"] as? String ?? tmp_date) ?? Date()
        if let begin_timestamp = dictionary["begin_timestamp"] as? Timestamp {
            begin = begin_timestamp.dateValue()
        }
        var end =  dfu.iso8601Formatter.date(from: dictionary["end"] as? String ?? tmp_date) ?? Date()
        if let end_timestamp = dictionary["end_timestamp"] as? Timestamp {
            end = end_timestamp.dateValue()
        }
        let conferenceName = dictionary["conference"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""

        let includes = dictionary["includes"] as? String ?? ""
        let link = dictionary["link"] as? String ?? ""
        let title = dictionary["title"] as? String ?? ""

        var location: HTLocationModel?
        if let locationValues = dictionary["location"] as? [String: Any] {
            location = HTLocationModel(dictionary: locationValues)
        }

        var speakers: [HTSpeaker] = []
        if let speakersValues = dictionary["speakers"] as? [Any] {

            speakers = speakersValues.compactMap { (element) -> HTSpeaker? in
                if let element = element as? [String: Any], let speaker = HTSpeaker(dictionary: element) {
                    return speaker
                }

                return nil
            }
        }

        var type: HTEventType?
        if let typeValues = dictionary["type"] as? [String: Any] {
            type = HTEventType(dictionary: typeValues)
        }

        guard  let typeVal = type, let locationVal = location else {
            return nil
        }

        self.init(id: id, conferenceName: conferenceName, description: description, begin: begin, end: end, includes: includes, links: link, title: title, location: locationVal, speakers: speakers, type: typeVal)
    }
}

struct HTLocationModel: Codable {
    var id: Int
    var conferenceName: String
    var name: String
    var hotel: String
}

extension HTLocationModel: Document {
    init?(dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let conferenceName = dictionary["conference"] as? String ?? ""
        let name = dictionary["name"] as? String ?? ""
        let hotel = dictionary["hotel"] as? String ?? ""

        self.init(id: id, conferenceName: conferenceName, name: name, hotel: hotel)
    }
}

struct HTSpeaker: Codable, Equatable {
    var id: Int
    var conferenceName: String
    var description: String
    var link: String
    var name: String
    var title: String
    var twitter: String
    var events: [HTEventModel]

    static func ==(lhs: HTSpeaker, rhs: HTSpeaker) -> Bool {
        if lhs.id == rhs.id && lhs.name == rhs.name && lhs.description == rhs.description {
            return true
        } else {
            return false
        }
    }
}

extension HTSpeaker: Document {
    init?(dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let conferenceName = dictionary["conference"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        let link = dictionary["link"] as? String ?? ""
        let name = dictionary["name"] as? String ?? ""
        let title = dictionary["title"] as? String ?? ""
        let twitter = dictionary["twitter"] as? String ?? ""

        var events: [HTEventModel] = []
        if let eventsValues = dictionary["events"] as? [Any] {

            events = eventsValues.compactMap { (element) -> HTEventModel? in
                if let element = element as? [String: Any], let event = HTEventModel(dictionary: element) {
                    return event
                }

                return nil
            }
        }

        self.init(id: id, conferenceName: conferenceName, description: description, link: link, name: name, title: title, twitter: twitter, events: events)
    }
}

struct HTEventType: Codable, Equatable {
    var id: Int
    var color: String
    var conferenceName: String
    var name: String
    var description: String
    var tags: String

    static func ==(lhs: HTEventType, rhs: HTEventType) -> Bool {
        if lhs.id == rhs.id && lhs.name == rhs.name {
            return true
        } else {
            return false
        }
    }
}

extension HTEventType: Document {
    init?(dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let color = dictionary["color"] as? String ?? ""
        let conferenceName = dictionary["conference"] as? String ?? ""
        let name = dictionary["name"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        let tags = dictionary["tags"] as? String ?? ""

        self.init(id: id, color: color, conferenceName: conferenceName, name: name, description: description, tags: tags)
    }
}
