//
//  EventCell.swift
//  hackertracker
//
//  Created by Chris Mays on 1/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import Foundation
import UIKit

public class EventCell : UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.backgroundGray
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(event : Event) {
        let beginDate = DateFormatterUtility.dayOfWeekTimeFormatter.string(from: event.begin as Date)
        let endDate = DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end as Date)

        guard let textLabel = textLabel, let detailTextLabel = detailTextLabel else {
            //This should only happen if the tableview cell style is changed
            fatalError("Failed to load the textLabel and/or detailTextLabel")
        }

        textLabel.text = event.title

        if (event.starred) {
            textLabel.text = "** \(event.title) **"
            textLabel.textColor = UIColor.deepPurple
        } else {
            textLabel.text = event.title
            textLabel.textColor = UIColor.white
        }

        detailTextLabel.text = "\(beginDate)-\(endDate) (\(event.location))"
        detailTextLabel.textColor = UIColor.init(colorLiteralRed: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
    }
}
