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
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var color: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.backgroundGray
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.backgroundGray
    }

    func bind(event : Event) {
        let eventTime = DateFormatterUtility.hourMinuteTimeFormatter.string(from:event.start_date as Date) + "-" + DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end_date as Date)
        
        title.text = event.title

        if (event.starred) {
            switch(event.entry_type) {
                case "Official":
                    color.backgroundColor = UIColor.deepPurple
                    break
                case "Contest":
                    color.backgroundColor = UIColor.blue
                    break
                case "Event":
                    color.backgroundColor = UIColor.red
                    break
                case "Party":
                    color.backgroundColor = UIColor.cyan
                    break
                case "Kids":
                    color.backgroundColor = UIColor.green
                    break
                case "Skytalks":
                    color.backgroundColor = UIColor.orange
                    break
                case "Villages":
                    color.backgroundColor = UIColor.yellow
                    break
                case "Workshop":
                    color.backgroundColor = UIColor.purple
                default:
                    color.backgroundColor = UIColor.white
                    break
            }
        } else {
            color.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        }

        
        if event.location.isEmpty {
            subtitle.text = "Location in description"
        } else {
            subtitle.text = event.location
        }
        
        time.text = eventTime
    }
}
