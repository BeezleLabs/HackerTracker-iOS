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
            return UIColor.init(colorLiteralRed: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        }
    }

    static var deepPurple : UIColor {
        get {
            return UIColor(red: 120/255.0, green: 114/255.0, blue: 255/255.0, alpha: 1)
        }
    }
}
