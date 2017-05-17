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
        //fatalError("init(coder:) has not been implemented")
    }

    func bind(event : Event) {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "PDT")
        df.dateFormat = "E"
        df.locale = Locale(identifier: "en_US_POSIX")
        
        let eventDay = df.string(from: event.begin as Date)
        
        df.dateFormat = "HH:mm"
        let eventTime = df.string(from:event.begin as Date) + "-" + df.string(from: event.end as Date)

        /*guard let title = textLabel, let subtitle = detailTextLabel else {
            //This should only happen if the tableview cell style is changed
            fatalError("Failed to load the textLabel and/or detailTextLabel")
        }*/

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
