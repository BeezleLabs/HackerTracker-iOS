//
//  HTHomeTabBarController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit

class HTHomeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        self.moreNavigationController.view.backgroundColor = UIColor.backgroundGray
        self.moreNavigationController.navigationBar.backgroundColor = UIColor.backgroundGray
        if let windowSize = UIApplication.shared.keyWindow?.frame.size {
            let image = UIImage.mainHeaderImage(scaledToWidth: windowSize.width, visibleRect: CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y, width:self.view.frame.size.width, height: 64))
            self.moreNavigationController.navigationBar.setBackgroundImage(image, for: .default)
            self.moreNavigationController.navigationBar.barStyle = .black
        } else {
            self.moreNavigationController.navigationBar.backgroundColor = UIColor.backgroundGray
        }
        self.moreNavigationController.view.tintColor = UIColor.gray
        
        /*let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe) */
    }
    
   /* @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            self.selectedIndex += 1
        }
        if sender.direction == .right {
            self.selectedIndex -= 1
        }
    }*/
}
