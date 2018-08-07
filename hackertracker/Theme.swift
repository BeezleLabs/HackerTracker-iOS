//
//  Theme.swift
//  hackertracker
//
//  Created by Chris Mays on 1/16/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static var backgroundGray : UIColor {
        get {
            return UIColor.init(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        }
    }

    static var deepPurple : UIColor {
        get {
            return UIColor(red: 120/255.0, green: 114/255.0, blue: 255/255.0, alpha: 1)
        }
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension UIFont {
    static var bungee: UIFont {
        get {
            guard let customFont = UIFont(name: "Bungee", size: 20.0) else {
                fatalError("Failed to load Bungee font")
            }
            if #available(iOS 11.0, *) {
                return UIFontMetrics.default.scaledFont(for: customFont)
            } else {
                return customFont
            }
        }
    }
    
    static var larseittBold: UIFont {
        get {
            guard let customFont = UIFont(name: "Larseitt Bold", size: 17.0) else {
                fatalError("Failed to load Larseitt font")
            }
            if #available(iOS 11.0, *) {
                return UIFontMetrics.default.scaledFont(for: customFont)
            } else {
                return customFont
            }
        }
    }
    
    static var larseitt: UIFont {
        get {
            guard let customFont = UIFont(name: "Larseitt", size: 14.0) else {
                fatalError("Failed to load Larseitt font")
            }
            if #available(iOS 11.0, *) {
                return UIFontMetrics.default.scaledFont(for: customFont)
            } else {
                return customFont
            }
        }
    }
}
