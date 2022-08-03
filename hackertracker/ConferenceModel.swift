//
//  ConferenceModel.swift
//  hackertracker
//
//  Created by Christopher Mays on 6/18/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import FirebaseFirestore
import Foundation

struct ConferenceModel: Codable {
    var id: Int
    var name: String
    var code: String
    var endDate: String
    var startDate: String
    var timeZone: String
    var coc: String
    var supportDoc: String
    var startTimestamp: Date
    var endTimestamp: Date
    var maps: [HTMapModel]
    var hidden: Bool
}

extension ConferenceModel: Document {
    init?(dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let name = dictionary["name"] as? String ?? ""
        let code = dictionary["code"] as? String ?? ""
        let endDate = dictionary["end_date"] as? String ?? ""
        let startDate = dictionary["start_date"] as? String ?? ""
        let tmpDate = "2019-01-01T00:00:00.000-0000"
        var startTimestamp = DateFormatterUtility.shared.iso8601Formatter.date(from: tmpDate) ?? Date()
        if let startTS = dictionary["start_timestamp"] as? Timestamp {
            startTimestamp = startTS.dateValue()
        }
        var endTimestamp = DateFormatterUtility.shared.iso8601Formatter.date(from: tmpDate) ?? Date()
        if let endTS = dictionary["end_timestamp"] as? Timestamp {
            endTimestamp = endTS.dateValue()
        }
        let timeZone = dictionary["timezone"] as? String ?? ""
        let coc = dictionary["codeofconduct"] as? String ?? ""
        let supportDoc = dictionary["supportdoc"] as? String ?? ""
        var maps: [HTMapModel] = []

        if let mapValues = dictionary["maps"] as? [Any] {
            maps = mapValues.compactMap { element -> HTMapModel? in
                if let element = element as? [String: Any], let map = HTMapModel(dictionary: element) {
                    return map
                }

                return nil
            }
        }
        let hidden = dictionary["hidden"] as? Bool ?? false

        self.init(id: id, name: name, code: code, endDate: endDate, startDate: startDate, timeZone: timeZone, coc: coc, supportDoc: supportDoc, startTimestamp: startTimestamp, endTimestamp: endTimestamp, maps: maps, hidden: hidden)
    }
}

struct HTMapModel: Codable {
    var file: String
    var name: String
}

extension HTMapModel: Document {
    init?(dictionary: [String: Any]) {
        let name = dictionary["name"] as? String ?? ""
        let file = dictionary["file"] as? String ?? ""

        self.init(file: file, name: name)
    }
}

struct HTArticleModel: Codable {
    var name: String
    var text: String
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case name, text, updatedAt = "updated_at"
    }
}

extension HTArticleModel: Document {
    init?(dictionary: [String: Any]) {
        let name = dictionary["name"] as? String ?? ""
        let text = dictionary["text"] as? String ?? ""
        let tmpDate = "2019-01-01T00:00:00.000-0000"
        var updatedAt = DateFormatterUtility.shared.iso8601Formatter.date(from: tmpDate) ?? Date()
        if let updatedTS = dictionary["updated_at"] as? Timestamp {
            updatedAt = updatedTS.dateValue()
        }

        self.init(name: name, text: text, updatedAt: updatedAt)
    }
}

struct HTFAQModel: Codable {
    var question: String
    var answer: String
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case question, answer, updatedAt = "updated_at"
    }
}

extension HTFAQModel: Document {
    init?(dictionary: [String: Any]) {
        let question = dictionary["question"] as? String ?? ""
        let answer = dictionary["answer"] as? String ?? ""
        let tmpDate = "2019-01-01T00:00:00.000-0000"
        var updatedAt = DateFormatterUtility.shared.iso8601Formatter.date(from: tmpDate) ?? Date()
        if let updateTS = dictionary["updated_at"] as? Timestamp {
            updatedAt = updateTS.dateValue()
        }
        self.init(question: question, answer: answer, updatedAt: updatedAt)
    }
}

struct HTVendorModel: Codable {
    var name: String
    var desc: String
    var link: String
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case name, desc, link, updatedAt = "updated_at"
    }
}

extension HTVendorModel: Document {
    init?(dictionary: [String: Any]) {
        let name = dictionary["name"] as? String ?? ""
        let desc = dictionary["description"] as? String ?? ""
        let link = dictionary["link"] as? String ?? ""
        let tmpDate = "2019-01-01T00:00:00.000-0000"
        var updatedAt = DateFormatterUtility.shared.iso8601Formatter.date(from: tmpDate) ?? Date()
        if let updateTS = dictionary["updated_at"] as? Timestamp {
            updatedAt = updateTS.dateValue()
        }

        self.init(name: name, desc: desc, link: link, updatedAt: updatedAt)
    }
}
