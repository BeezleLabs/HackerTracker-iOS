//
//  HTEventModel.swift
//  hackertracker
//
//  Created by Christopher Mays on 6/18/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import FirebaseFirestore
import Foundation

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
    var links: [HTLink]
    var title: String
    var location: HTLocationModel
    var speakers: [HTSpeaker]
    var type: HTEventType
    var tagIds: [Int]
    var tags: String
}

struct UserEventModel: Codable, Equatable {
    var event: HTEventModel
    var bookmark: Bookmark

    static func == (lhs: UserEventModel, rhs: UserEventModel) -> Bool {
        if lhs.event.id == rhs.event.id && lhs.event.title == rhs.event.title && lhs.event.description == rhs.event.description {
            return true
        } else {
            return false
        }
    }
}

extension HTEventModel: Document {
    init?(dictionary: [String: Any]) { // swiftlint:disable:this function_body_length
        let dfu = DateFormatterUtility.shared
        let tmpDate = "2019-01-01T00:00:00.000-0000"
        let id = dictionary["id"] as? Int ?? 0
        var begin = dfu.iso8601Formatter.date(from: dictionary["begin"] as? String ?? tmpDate) ?? Date()
        if let beginTimestamp = dictionary["begin_timestamp"] as? Timestamp {
            begin = beginTimestamp.dateValue()
        }
        var end = dfu.iso8601Formatter.date(from: dictionary["end"] as? String ?? tmpDate) ?? Date()
        if let endTimestamp = dictionary["end_timestamp"] as? Timestamp {
            end = endTimestamp.dateValue()
        }
        let conferenceName = dictionary["conference"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""

        let includes = dictionary["includes"] as? String ?? ""
        let title = dictionary["title"] as? String ?? ""

        var location: HTLocationModel?
        if let locationValues = dictionary["location"] as? [String: Any] {
            location = HTLocationModel(dictionary: locationValues)
        }

        var links: [HTLink] = []

        if let linksValues = dictionary["links"] as? [Any] {
            links = linksValues.compactMap { element -> HTLink? in
                if let element = element as? [String: Any], let link = HTLink(dictionary: element) {
                    return link
                }
                return nil
            }
        }

        var speakers: [HTSpeaker] = []
        if let speakersValues = dictionary["speakers"] as? [Any] {
            speakers = speakersValues.compactMap { element -> HTSpeaker? in
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

        var tagIds: [Int] = []
        if let tagIdVals = dictionary["tag_ids"] as? [Int] {
            tagIds = tagIdVals
        }

        let tags: String = dictionary["tags"] as? String ?? ""

        self.init(id: id,
                  conferenceName: conferenceName,
                  description: description,
                  begin: begin,
                  end: end,
                  includes: includes,
                  links: links,
                  title: title,
                  location: locationVal,
                  speakers: speakers,
                  type: typeVal,
                  tagIds: tagIds,
                  tags: tags
        )
    }
}

struct HTLocationModel: Codable, Identifiable {
    var id: Int
    var conferenceId: Int
    var conferenceName: String
    var name: String
    var hotel: String
    var defaultStatus: String
    var schedule: [HTSchedule]
    var hierExtentLeft: Int
    var hierExtentRight: Int
    var hierDepth: Int
    var parentId: Int
    var peerSortOrder: Int
    var shortName: String
}

extension HTLocationModel: Document {
    init?(dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let conferenceId = dictionary["conference_id"] as? Int ?? 0
        let conferenceName = dictionary["conference"] as? String ?? ""
        let name = dictionary["name"] as? String ?? ""
        let hotel = dictionary["hotel"] as? String ?? ""
        let defaultStatus = dictionary["default_status"] as? String ?? ""
        var schedule: [HTSchedule] = []
        if let scheduleValues = dictionary["schedule"] as? [Any] {
            schedule = scheduleValues.compactMap { element -> HTSchedule? in
                if let element = element as? [String: Any], let sched = HTSchedule(dictionary: element) {
                    return sched
                }
                return nil
            }
        }
        let hierExtentLeft = dictionary["hier_extent_left"] as? Int ?? 0
        let hierExtentRight = dictionary["hier_extent_right"] as? Int ?? 0
        let hierDepth = dictionary["hier_depth"] as? Int ?? 0
        let parentId = dictionary["parent_id"] as? Int ?? 0
        let peerSortOrder = dictionary["peer_sort_order"] as? Int ?? 0
        let shortName = dictionary["short_name"] as? String ?? ""
        self.init(id: id, conferenceId: conferenceId, conferenceName: conferenceName, name: name, hotel: hotel,
                  defaultStatus: defaultStatus, schedule: schedule, hierExtentLeft: hierExtentLeft,
                  hierExtentRight: hierExtentRight, hierDepth: hierDepth, parentId: parentId,
                  peerSortOrder: peerSortOrder, shortName: shortName)
    }
}

struct HTSchedule: Codable {
    var begin: Date
    var end: Date
    var status: String
}

extension HTSchedule: Document {
    init?(dictionary: [String: Any]) {
        let dfu = DateFormatterUtility.shared
        let tmpDate = "2019-01-01T00:00:00.000-0000"
        var begin = dfu.locationTimeFormatter.date(from: dictionary["begin"] as? String ?? tmpDate) ?? Date()
        if let beginTimestamp = dictionary["begin"] as? Timestamp {
            begin = beginTimestamp.dateValue()
        }
        var end = dfu.locationTimeFormatter.date(from: dictionary["end"] as? String ?? tmpDate) ?? Date()
        if let endTimestamp = dictionary["end"] as? Timestamp {
            end = endTimestamp.dateValue()
        }
        let status = dictionary["status"] as? String ?? ""

        self.init(begin: begin, end: end, status: status)
    }
}

struct HTLink: Codable {
    var label: String
    var type: String
    var url: String
}

extension HTLink: Document {
    init?(dictionary: [String: Any]) {
        let label = dictionary["label"] as? String ?? ""
        let type = dictionary["type"] as? String ?? ""
        let url = dictionary["url"] as? String ?? ""

        self.init(label: label, type: type, url: url)
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

    static func == (lhs: HTSpeaker, rhs: HTSpeaker) -> Bool {
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
            events = eventsValues.compactMap { element -> HTEventModel? in
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

    static func == (lhs: HTEventType, rhs: HTEventType) -> Bool {
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
