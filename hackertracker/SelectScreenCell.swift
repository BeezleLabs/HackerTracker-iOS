//
//  SelectScreenCell.swift
//  hackertracker
//
//  Created by Seth W Law on 8/8/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import UIKit

class SelectScreenCell: UITableViewCell {
    @IBOutlet private var startupSwitch: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()

        startupSwitch.backgroundColor = .black
        startupSwitch.selectedSegmentTintColor = .white
        startupSwitch.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        startupSwitch.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)

        let startScreen = UserDefaults.standard.string(forKey: "startScreen")
        switch startScreen {
        case "Schedule":
            startupSwitch.selectedSegmentIndex = 1
        case "Bookmarks":
            startupSwitch.selectedSegmentIndex = 2
        default:
            startupSwitch.selectedSegmentIndex = 0
        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction private func changeScreen(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Information", forKey: "startScreen")

        // NSLog("switching to segment \(sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "")")
    }
}
