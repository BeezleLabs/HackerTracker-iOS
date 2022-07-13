//
//  ColorUtility.swift
//  hackertracker
//
//  Created by caleb on 6/15/22.
//

import Foundation
import SwiftUI
import UIKit

// modified from https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
public extension UIColor {
    convenience init?(hex: String) {
        let red, green, blue, alpha: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
                    blue = CGFloat(hexNumber & 0x0000FF) / 255.0
                    alpha = CGFloat(1.0)

                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }

        return nil
    }
}

func hexSwiftUIColor(hex: String) -> Color {
    return Color(UIColor(hex: hex) ?? .gray)
}
