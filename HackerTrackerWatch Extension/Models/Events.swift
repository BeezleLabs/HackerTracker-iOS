//
//  Events.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 10/28/20.
//

import SwiftUI

struct Events: Codable {
    let nextPageToken: String?
    let documents: [EventDocument]
}

struct EventDocument: Codable {
    let createTime: String
    let fields: EventFields
    let name: String
    let updateTime: String
}

struct EventFields: Codable {
    let begin: StringValue
    let beginTimestamp: TimestampValue
    let description: StringValue
    let end: StringValue
    let endTimestamp: TimestampValue
    let id: IntegerValue
    let includes: StringValue
    let updated: StringValue
    let link: StringValue
    let speakers: Speakers
    let title: StringValue
    let type: EventType
    let location: Location
    let conference: StringValue

    private enum CodingKeys: String, CodingKey {
        case begin
        case beginTimestamp = "begin_timestamp"
        case description
        case end
        case endTimestamp = "end_timestamp"
        case id
        case includes
        case updated
        case link
        case speakers
        case title
        case type
        case location
        case conference
    }
}

struct Speakers: Codable {
    let arrayValue: SpeakerArrayValues
}

struct SpeakerArrayValues: Codable {
    let values: [SpeakerValues]?
}

struct SpeakerValues: Codable {
    let mapValue: SpeakersMapValue
}

struct SpeakersMapValue: Codable {
    let fields: SpeakersFields
}

struct SpeakersFields: Codable {
    let title: StringValue?
    let name: StringValue
    let id: IntegerValue
}

struct EventType: Codable {
    let mapValue: TypeMapValue
}

struct TypeMapValue: Codable {
    let fields: TypeFields
}

struct TypeFields: Codable {
    let id: IntegerValue
    let conference: StringValue?
    let updatedAt: StringValue?
    let name: StringValue
    let color: StringValue

    private enum CodingKeys: String, CodingKey {
        case id
        case conference
        case updatedAt = "updated_at"
        case name
        case color
    }
}

struct Location: Codable {
    let mapValue: LocationMapValue
}

struct LocationMapValue: Codable {
    let fields: LocationFields
}

struct LocationFields: Codable {
    let id: IntegerValue
    let conference: StringValue
    let updatedAt: StringValue
    let name: StringValue
    let hotel: StringValue?

    private enum CodingKeys: String, CodingKey {
        case id
        case conference
        case updatedAt = "updated_at"
        case name
        case hotel
    }
}

extension EventType {
    var swiftuiColor: Color {
        Color(
            UIColor(hex: mapValue.fields.color.stringValue) ?? .purple)
    }
}
