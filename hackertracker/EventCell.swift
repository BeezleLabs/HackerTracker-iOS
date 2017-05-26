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

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var color: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.backgroundGray
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(event : Event) {
        let eventDay = DateFormatterUtility.partialDayOfWeekFormatter.string(from: event.begin as Date)
        let eventTime = DateFormatterUtility.hourMinuteTimeFormatter.string(from:event.begin as Date) + "-" + DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end as Date)
        
        title.text = event.title

        if (event.starred) {
            color.backgroundColor = UIColor.deepPurple
        } else {
            color.backgroundColor = UIColor.backgroundGray
        }

        subtitle.text = event.location
        day.text = eventDay
        time.text = eventTime
    }
}
