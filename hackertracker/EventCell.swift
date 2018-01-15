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
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        backgroundColor = UIColor.backgroundGray
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        selectedBackgroundView = selectedView
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        let oldColor = color.backgroundColor
        super.setSelected(selected, animated: animated)
        color.backgroundColor = oldColor
    }

    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let oldColor = color.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        color.backgroundColor = oldColor
    }

    func bind(event : Event) {
        let eventTime = DateFormatterUtility.hourMinuteTimeFormatter.string(from:event.start_date as Date) + "-" + DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end_date as Date)
        
        title.text = event.title

        color.backgroundColor = color(for: event)
        
        let speakers : [Speaker]
        
        let dataRequest = DataRequestManager(managedContext: getContext())
        if let retrievedSpeakers = dataRequest.getSpeakersForEvent(event.index)
        {
            speakers = retrievedSpeakers
        } else {
            speakers = []
        }
        
        if event.location.isEmpty {
            subtitle.text = "Location in description"
        } else {
            subtitle.text = event.location
            for s in speakers {
                let split = s.who.split(separator: " ")
                //let split = s.who.characters.split(separator: " ")
                let last    = String(split.suffix(1).joined(separator: [" "]))
                subtitle.text = "\(String(describing: subtitle.text!)) - \(last)"
            }
        }

        time.text = eventTime
    }

    func color(for event: Event) -> UIColor {
        var color = UIColor.gray.withAlphaComponent(0.4)
        if (event.starred) {
            switch(event.entry_type) {
            case "Official":
                color = .deepPurple
                break
            case "Workshops":
                color = .blue
                break
            case "Seminars":
                color = .red
                break
            case "Contests":
                color = .green
                break
            case "Kids":
                color = .cyan
                break
            case "Skytalks":
                color = .orange
                break
            case "Villages":
                color = .yellow
                break
            case "Workshop":
                color = .purple
                break
            default:
                color = .white
                break
            }
        }

        return color
    }

}
