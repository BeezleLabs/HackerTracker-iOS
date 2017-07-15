//
//  HTEventsNavViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/5/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit
import CoreGraphics

class HTEventsNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = #imageLiteral(resourceName: "dc-25-wallpaper-blurred")
        
        var  transformScale : CGFloat = 1.0
        
        if let windowSize = UIApplication.shared.keyWindow?.frame.size.width {
            transformScale = windowSize/image.size.width
        }
        
        let size = image.size.applying(CGAffineTransform(scaleX: transformScale, y: transformScale))
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:size.width, height: 64), true, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.navigationBar.setBackgroundImage(scaledImage, for: .default)
    }

}
