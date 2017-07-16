//
//  HTSplitViewController.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/15/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class HTSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = true
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {

        guard let navController = secondaryViewController as? UINavigationController else {
            return false
        }

        guard let eventDetailController = navController.topViewController as? HTEventDetailViewController else {
            // If the HTEventDetailViewController is not the topVC then it must be
            // a placeholder view controller that needs to collapse.
            return true
        }

        if eventDetailController.event == nil {
            // There is no event in this HTEventDetailViewController, so collapse the empty detail view controller.
            return true
        } else {
            return false
        }
        
    }

}
