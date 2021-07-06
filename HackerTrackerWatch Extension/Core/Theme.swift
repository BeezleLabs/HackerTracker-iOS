//
//  Theme.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 6/23/21.
//

import SwiftUI

class Theme {
    let colorHex = ["#eec643", "#e25238", "#dc8530", "#4999e5", "#64d576"]
    let colors = ["#eec643", "#e25238", "#dc8530", "#4999e5", "#64d576"].compactMap { Color(UIColor(hex: $0) ?? .purple) }
    let font = ThemeFont()
    var index = 0

    func carousel() -> Color {
        if index >= colors.count {
            index = 0
        }

        let color = colors[index]
        index += 1

        return color
    }
}

struct ThemeFont {
    let bold = "Futura Bold"
    let regular = "Futura Medium"
    let italic = "Futura Medium Italic"
}
