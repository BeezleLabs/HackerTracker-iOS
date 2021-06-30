//
//  ConferenceModel.swift
//  hackertracker
//
//  Created by Christopher Mays on 6/18/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct ConferenceModel: Codable {
    var id: Int
    var name: String
    var code: String
    var endDate: String
    var startDate: String
    var tz: String
    var coc: String
    var start_timestamp: Date
    var end_timestamp: Date
    var maps: [HTMapModel]
}

extension ConferenceModel: Document {
    init?(dictionary: [String: Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let name = dictionary["name"] as? String ?? ""
        let code = dictionary["code"] as? String ?? ""
        let endDate = dictionary["end_date"] as? String ?? ""
        let startDate = dictionary["start_date"] as? String ?? ""
        let tmp_date = "2019-01-01T00:00:00.000-0000"
        var start_timestamp = DateFormatterUtility.shared.iso8601Formatter.date(from: tmp_date) ?? Date()
        if let start_tz = dictionary["start_timestamp"] as? Timestamp {
            start_timestamp = start_tz.dateValue()
        }
        var end_timestamp = DateFormatterUtility.shared.iso8601Formatter.date(from: tmp_date) ?? Date()
        if let end_tz = dictionary["end_timestamp"] as? Timestamp {
            end_timestamp = end_tz.dateValue()
        }
        let tz = dictionary["timezone"] as? String ?? ""
        let coc = dictionary["codeofconduct"] as? String ?? ""
        var maps: [HTMapModel] = []

        if let mapValues = dictionary["maps"] as? [Any] {
            maps = mapValues.compactMap { (element) -> HTMapModel? in
                if let element = element as? [String: Any], let map = HTMapModel(dictionary: element) {
                    return map
                }

                return nil
            }
        }

        self.init(id: id, name: name, code: code, endDate: endDate, startDate: startDate, tz: tz, coc: coc, start_timestamp: start_timestamp, end_timestamp: end_timestamp, maps: maps)
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
    var updated_at: Date

}

extension HTArticleModel: Document {
    init?(dictionary: [String: Any]) {
        let name = dictionary["name"] as? String ?? ""
        let text = dictionary["text"] as? String ?? ""
        let tmp_date = "2019-01-01T00:00:00.000-0000"
        var updated_at = DateFormatterUtility.shared.iso8601Formatter.date(from: tmp_date) ?? Date()
        if let updated_ts = dictionary["updated_at"] as? Timestamp {
            updated_at = updated_ts.dateValue()
        }

        self.init(name: name, text: text, updated_at: updated_at)
    }
}

struct HTFAQModel: Codable {
    var question: String
    var answer: String
    var updated_at: Date
}

extension HTFAQModel: Document {
    init?(dictionary: [String: Any]) {
        let question = dictionary["question"] as? String ?? ""
        let answer = dictionary["answer"] as? String ?? ""
        let tmp_date = "2019-01-01T00:00:00.000-0000"
        var updated_at = DateFormatterUtility.shared.iso8601Formatter.date(from: tmp_date) ?? Date()
        if let update_tz = dictionary["updated_at"] as? Timestamp {
            updated_at = update_tz.dateValue()
        }
        self.init(question: question, answer: answer, updated_at: updated_at)
    }
}

struct HTVendorModel: Codable {
    var name: String
    var desc: String
    var link: String
    var updated_at: Date

}

extension HTVendorModel: Document {
    init?(dictionary: [String: Any]) {
        let name = dictionary["name"] as? String ?? ""
        let desc = dictionary["description"] as? String ?? ""
        let link = dictionary["link"] as? String ?? ""
        let tmp_date = "2019-01-01T00:00:00.000-0000"
        var updated_at = DateFormatterUtility.shared.iso8601Formatter.date(from: tmp_date) ?? Date()
        if let update_tz = dictionary["updated_at"] as? Timestamp {
            updated_at = update_tz.dateValue()
        }

        self.init(name: name, desc: desc, link: link, updated_at: updated_at)
    }
}
