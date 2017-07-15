//
//  HTEventsNavViewController.swift
//  hackertracker
//
//  Created by Seth Law on 5/5/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIImage {
    static func mainHeaderImage(scaledToWidth:CGFloat, visibleSize : CGSize? = nil) -> UIImage {
        let image = #imageLiteral(resourceName: "dc-25-wallpaper-blurred")
        
        var  transformScale : CGFloat = 1.0
        
        transformScale = scaledToWidth/image.size.width
    
        let size = image.size.applying(CGAffineTransform(scaleX: transformScale, y: transformScale))
        
        var cropSize = visibleSize ?? size
        
        cropSize.height = min(visibleSize?.height ?? CGFloat.infinity, size.height)
        
        UIGraphicsBeginImageContextWithOptions(cropSize, true, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? UIImage()
    }
}

class HTEventsNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let windowSize = UIApplication.shared.keyWindow?.frame.size {
            setNavBarImage(screenSize: windowSize)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.setNavBarImage(screenSize: size)
        }, completion: nil)
        
    }

    func setNavBarImage(screenSize : CGSize)
    {
        let image = UIImage.mainHeaderImage(scaledToWidth: screenSize.width, visibleSize:  CGSize(width:screenSize.width, height: 64))
        self.navigationBar.setBackgroundImage(image, for: .default)
    }
}
