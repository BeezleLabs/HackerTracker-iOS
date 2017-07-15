//
//  HTEventSplitViewController.swift
//  hackertracker
//
//  Created by Benjamin Humphries on 7/15/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class HTEventSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = true
        self.delegate = self
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {

        if let navController = secondaryViewController as? UINavigationController,
            let eventDetailController = navController.topViewController as? HTEventDetailViewController,
            eventDetailController.event == nil {
            // Return true to indicate that we have handled the collapse by doing nothing;
            // the secondary controller will be discarded.
            return true
        } else {
            return false
        }

    }

}
