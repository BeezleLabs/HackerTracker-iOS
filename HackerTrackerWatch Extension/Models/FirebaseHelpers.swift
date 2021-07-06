//
//  FirebaseHelpers.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 10/28/20.
//

import Foundation

struct IntegerValue: Codable {
    let integerValue: String
}

struct StringValue: Codable {
    let stringValue: String
}

struct BooleanValue: Codable {
    let booleanValue: Bool
}

struct TimestampValue: Codable {
    let timestampValue: Date
}
