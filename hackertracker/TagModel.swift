//
//  TagModel.swift
//  hackertracker
//
//  Created by Seth W Law on 8/3/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import FirebaseFirestore
import Foundation

struct HTTagType: Codable {
    var category: String
    var id: Int
    var isBrowsable: Bool
    var isSingleValued: Bool
    var label: String
    var sortOrder: Int
    var tags: [HTTag]
}

extension HTTagType: Document {
    init?(dictionary: [String: Any]) {
        let category = dictionary["category"] as? String ?? ""
        let id = dictionary["id"] as? Int ?? 0
        let isBrowsable = dictionary["is_browsable"] as? Bool ?? false
        let isSingleValued = dictionary["is_single_valued"] as? Bool ?? false
        let label = dictionary["label"] as? String ?? ""
        let sortOrder = dictionary["sort_order"] as? Int ?? 1
        var tags: [HTTag] = []

        if let tagValues = dictionary["tags"] as? [Any] {
            tags = tagValues.compactMap { element -> HTTag? in
                if let element = element as? [String: Any], let map = HTTag(dictionary: element) {
                    return map
                }
                return nil
            }
        }

        self.init(category: category, id: id, isBrowsable: isBrowsable, isSingleValued: isSingleValued, label: label, sortOrder: sortOrder, tags: tags)
    }
}

struct HTTag: Codable, Equatable {
    var colorBackground: String
    var colorForeground: String
    var description: String
    var id: Int
    var label: String
    var sortOrder: Int

    static func == (lhs: HTTag, rhs: HTTag) -> Bool {
        if lhs.id == rhs.id && lhs.label == rhs.label {
            return true
        } else {
            return false
        }
    }
}

extension HTTag: Document {
    init?(dictionary: [String: Any]) {
        let colorBackground = dictionary["color_background"] as? String ?? ""
        let colorForeground = dictionary["color_foreground"] as? String ?? ""
        let description = dictionary["description"] as? String ?? ""
        let id = dictionary["id"] as? Int ?? 0
        let label = dictionary["label"] as? String ?? ""
        let sortOrder = dictionary["sort_order"] as? Int ?? 1

        self.init(colorBackground: colorBackground, colorForeground: colorForeground, description: description, id: id, label: label, sortOrder: sortOrder)
    }
}
