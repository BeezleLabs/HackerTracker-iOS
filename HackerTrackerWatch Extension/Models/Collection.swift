//
//  Collection.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 10/28/20.
//

import Combine
import Foundation

struct Collection: Codable {
    let nextPageToken: String?
    let documents: [CollectionDocument]
}

struct CollectionDocument: Codable {
    let fields: Fields
    let createTime: String
    let name: String
    let updateTime: String
}

struct Fields: Codable {
    let description: StringValue
    let id: IntegerValue
    let startDate: StringValue
    let endDate: StringValue
    let link: StringValue
    let code: StringValue
    let updatedAt: StringValue
    let hidden: BooleanValue
    let endTimestamp: TimestampValue
    let timezone: StringValue
    let name: StringValue
    let startTimestamp: TimestampValue
    let codeOfConduct: StringValue?

    private enum CodingKeys: String, CodingKey {
        case description
        case id
        case startDate = "start_date"
        case endDate = "end_date"
        case link
        case code
        case updatedAt = "updated_at"
        case hidden
        case timezone
        case endTimestamp = "end_timestamp"
        case name
        case startTimestamp = "start_timestamp"
        case codeOfConduct = "caseofconduct"
    }
}
