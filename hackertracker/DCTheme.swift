//
//  Theme.swift
//  hackertracker
//
//  Created by caleb on 6/17/22.
//

import SwiftUI

class Theme {
    let colors = ["#c16784", "#326295", "#71cc98", "#4b9560", "#c04c36"]
    let font = ThemeFont()
    var index = 0

    func carousel() -> Color {
        if index >= colors.count {
            index = 0
        }

        let color = colors[index]
        index += 1

        return Color(UIColor(hex: color) ?? .purple)
    }
}

struct ThemeFont {
    let bold = "Futura Bold"
    let regular = "Futura Medium"
    let italic = "Futura Medium Italic"
}

enum ThemeColors {
    static let pink = hexSwiftUIColor(hex: "#c16784")
    static let blue = hexSwiftUIColor(hex: "#326295")
    static let green = hexSwiftUIColor(hex: "#71cc98")
    static let drkGreen = hexSwiftUIColor(hex: "#4b9560")
    static let red = hexSwiftUIColor(hex: "#c04c36")
    static let gray = hexSwiftUIColor(hex: "#2D2D2D")
}
