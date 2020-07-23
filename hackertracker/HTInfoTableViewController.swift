//
//  HTInfoTableViewController.swift
//  hackertracker
//
//  Created by Seth W Law on 7/19/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import UIKit
import SwiftUI

class HTInfoTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // # Current More screen has 7 rows, return 8 if you want to show the DEF CON WiFi Setup
        // TODO: Automate this list
        return 7
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 5) {
            // Contact Us!
            let email = "hackertracker@defcon.org"
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

    }
    
    
    
    @IBSegueAction func showSettingsView(_ coder: NSCoder) -> UIViewController? {
        let view = UIHostingController(coder: coder, rootView: SettingsView())
        view?.view.backgroundColor = UIColor.backgroundGray
        view?.title = "Settings"
        return view
    }
    
}
