//
//  HTSettingsTableViewController.swift
//  hackertracker
//
//  Created by caleb on 7/24/20.
//  Copyright © 2020 Beezle Labs. All rights reserved.
//

import UIKit

class HTSettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundGray
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Display Local Time"
        cell.textLabel?.textColor = UIColor.white
        let preferLocalTime = UISwitch()
        preferLocalTime.addTarget(self, action: #selector(setLocalTimePreference(_:)), for: .valueChanged)
        preferLocalTime.isOn = UserDefaults.standard.bool(forKey: "PreferLocalTime")
        cell.accessoryView = preferLocalTime
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    @objc func setLocalTimePreference(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "PreferLocalTime")
        AnonymousSession.shared.currentConference = AnonymousSession.shared.currentConference
    }
}

