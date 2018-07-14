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
    static func mainHeaderImage(scaledToWidth:CGFloat, visibleRect : CGRect? = nil) -> UIImage {
        let image = #imageLiteral(resourceName: "header")
        
        var transformScale : CGFloat = 1.0
        
        transformScale = scaledToWidth/image.size.width
    
        let size = image.size.applying(CGAffineTransform(scaleX: transformScale, y: transformScale))
        
        var cropRect = visibleRect ?? CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        cropRect.size.height = min(visibleRect?.size.height ?? CGFloat.infinity, size.height)
        
        UIGraphicsBeginImageContextWithOptions(cropRect.size, true, 0.0)
        image.draw(in: CGRect(origin: CGPoint(x:-cropRect.origin.x, y:-cropRect.origin.y), size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? UIImage()
    }
}

class HTEventsNavViewController: UINavigationController {

    var lastSize : CGSize = CGSize.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let windowSize = UIApplication.shared.keyWindow?.frame.size {
            setNavBarImage(screenSize: windowSize)
        }
        //UIBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Bungee", size: 17)])
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            if let windowSize = UIApplication.shared.keyWindow?.frame.size {
                self.setNavBarImage(screenSize: windowSize)
            }
        }, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.view.frame.size.width != lastSize.width {
            lastSize = self.view.frame.size
            if let windowSize = UIApplication.shared.keyWindow?.frame.size {
                setNavBarImage(screenSize: windowSize)
            }
        }
    }

    func setNavBarImage(screenSize : CGSize)
    {
        let image = UIImage.mainHeaderImage(scaledToWidth: screenSize.width, visibleRect: CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y, width:self.view.frame.size.width, height: 64))
        self.navigationBar.setBackgroundImage(image, for: .default)
    }
}
