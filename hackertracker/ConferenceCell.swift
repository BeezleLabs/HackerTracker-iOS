//
//  ConferenceCell.swift
//  hackertracker
//
//  Created by Seth Law on 7/9/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class ConferenceCell: UITableViewCell {
    @IBOutlet private var name: UILabel!
    @IBOutlet private var dates: UILabel!
    @IBOutlet private var color: UIView!

    var conference: ConferenceModel?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        accessoryType = isSelected ? .checkmark : .none
        color.isHidden = !isSelected
    }

    func selectCell(_ select: Bool) {
        if select == true {
            accessoryType = .checkmark
            color.isHidden = false
        } else {
            accessoryType = .none
            color.isHidden = true
        }
    }

    func setConference(conference: ConferenceModel) {
        self.conference = conference
        self.name.text = self.conference?.name
        let dfu = DateFormatterUtility.shared
        if let startDate = dfu.yearMonthDayFormatter.date(from: (conference.startDate)), let endDate = dfu.yearMonthDayFormatter.date(from: (conference.endDate)) {
            let start = dfu.monthDayYearFormatter.string(from: startDate)
            let end = dfu.monthDayYearFormatter.string(from: endDate)
            self.dates.text = "\(start) - \(end)"
        }
    }
}
