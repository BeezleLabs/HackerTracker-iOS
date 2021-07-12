//
//  NSParagraphStyle+leftAlignedParagraph.swift
//  hackertracker
//
//  Created by Josh Asbury on 4/7/21.
//  Copyright © 2021 Beezle Labs. All rights reserved.
//

import class UIKit.NSParagraphStyle
import class UIKit.NSMutableParagraphStyle

extension NSParagraphStyle {
    static let leftAlignedParagraph: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        return style
    }()
}
