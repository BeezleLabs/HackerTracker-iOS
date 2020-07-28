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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(returnFromSettings(notification:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Table view data source
    
    enum SettingsCells: Int, CaseIterable {
        case localTime = 0
        case notification
    }
    
    override func numberOfSections(in _: UITableView) -> Int {
        return SettingsCells.allCases.count
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = SettingsCells.allCases[section]
        switch section {
        case .localTime: return 1
        case .notification: return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SettingsCells.allCases[indexPath.section]
        switch section {
        case .localTime:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Display Local Time"
            cell.textLabel?.textColor = UIColor.white
            let preferLocalTime = UISwitch()
            preferLocalTime.addTarget(self, action: #selector(setLocalTimePreference(_:)), for: .valueChanged)
            preferLocalTime.isOn = UserDefaults.standard.bool(forKey: "PreferLocalTime")
            cell.accessoryView = preferLocalTime
            cell.backgroundColor = UIColor.clear
            return cell
        case .notification:
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
            cell.textLabel?.text = "Notifications"
            cell.detailTextLabel?.text = "Turn on notifications"
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.numberOfLines = 3
            let detailTextTap = UITapGestureRecognizer(target: self, action: #selector(sendToSettings(_:)))
            cell.detailTextLabel?.addGestureRecognizer(detailTextTap)
            cell.detailTextLabel?.isUserInteractionEnabled = false
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
            let notificationSetting = UISwitch()
            notificationSetting.addTarget(self, action: #selector(notificationSetting(_:)), for: .valueChanged)
            notificationSetting.isOn = UserDefaults.standard.bool(forKey: "Notifications")
            cell.accessoryView = notificationSetting
            cell.backgroundColor = UIColor.clear
            
            if let status = NotificationUtility.status {
                switch status {
                case .authorized, .provisional:
                    notificationSetting.isEnabled = false
                    notificationSetting.isOn = true
                    cell.detailTextLabel?.isUserInteractionEnabled = true
                    cell.detailTextLabel?.text = "Notifications are enabled, to disable tap to go to system application settings and disallow notifications"
                case .denied:
                    notificationSetting.isEnabled = false
                    notificationSetting.isOn = false
                    cell.detailTextLabel?.isUserInteractionEnabled = true
                    cell.detailTextLabel?.text = "Notifications are disabled, to enable tap to go to system application settings and allow notifications"
                case .notDetermined:
                    notificationSetting.isEnabled = true
                    notificationSetting.isOn = false
                    cell.detailTextLabel?.isUserInteractionEnabled = false
                    cell.detailTextLabel?.text = "Turn on notifications"
                @unknown default:
                    break
                }
            }
            
            return cell
        }
    }
    
    @objc func setLocalTimePreference(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "PreferLocalTime")
        AnonymousSession.shared.currentConference = AnonymousSession.shared.currentConference
    }
    
    @objc func notificationSetting(_ sender: UISwitch) {
        if sender.isOn && sender.isEnabled {
            NotificationUtility.checkAndRequestAuthorization()
        }
    }
    
    @objc func sendToSettings(_: UITapGestureRecognizer) {
        if let url = URL(string: UIApplication.openSettingsURLString) { if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func returnFromSettings(notification _: Notification) {
        tableView.reloadData()
    }
}
