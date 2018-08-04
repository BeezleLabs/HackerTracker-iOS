//
//  EventCell.swift
//  hackertracker
//
//  Created by Chris Mays on 1/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import Foundation
import UIKit

protocol EventCellDelegate : class {
    func updatedEvents()
}

public class EventCell : UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var color: UIView!
    @IBOutlet weak var et_label: UILabel!
    @IBOutlet weak var favorited: UIImageView!
    
    weak var eventCellDelegate : EventCellDelegate? 
    var myEvent: Event?
    
    
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
        et_label.layer.backgroundColor = oldColor?.cgColor
        et_label.backgroundColor = oldColor
    }

    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let oldColor = color.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        color.backgroundColor = oldColor
        et_label.layer.backgroundColor = oldColor?.cgColor
        et_label.backgroundColor = oldColor
    }

    func bind(event : Event) {
        myEvent = event
        var eventTime = "TBD"
        if let start = event.start_date, let end = event.end_date {
            eventTime = DateFormatterUtility.hourMinuteTimeFormatter.string(from:start) + "-" + DateFormatterUtility.hourMinuteTimeFormatter.string(from: end)
        }
        
        title.text = event.title

        if let et = event.event_type, let col = et.color {
            color.backgroundColor = UIColor(hexString: (col))
            et_label.layer.borderColor = UIColor(hexString: col).cgColor
            et_label.layer.borderWidth = 1.0
            et_label.backgroundColor = UIColor(hexString: col)
            et_label.text = " \((event.event_type?.name!)!) "
            et_label.layer.masksToBounds = true
            et_label.layer.cornerRadius = 5
            
        } else {
            color.backgroundColor = UIColor.gray
            et_label.text = " "
        }
        
        if event.location?.id == 0 {
            subtitle.text = "Location in description"
        } else {
            if let n = event.location?.name {
                subtitle.text = "\(n) |"
            } else {
                subtitle.text = "TBA |"
            }
        }
        
        if event.starred {
            favorited.image = #imageLiteral(resourceName: "saved-active").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            favorited.tintColor = UIColor.white

        } else {
            favorited.image = #imageLiteral(resourceName: "saved-inactive").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            favorited.tintColor = UIColor.gray
        }

        
        let tr = UITapGestureRecognizer(target: self, action: #selector(tappedStar(sender:)))
        tr.delegate = self
        favorited.addGestureRecognizer(tr)
        favorited.isUserInteractionEnabled = true

        time.text = eventTime
    }
    
    @objc func tappedStar(sender: AnyObject) {
        if let e = myEvent {
            e.starred = !e.starred
            if e.starred {
                favorited.image = #imageLiteral(resourceName: "saved-active").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                favorited.tintColor = UIColor.white
                scheduleNotification(at: (myEvent?.start_date?.addingTimeInterval(-600))!,myEvent!)
            } else {
                favorited.image = #imageLiteral(resourceName: "saved-inactive").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                favorited.tintColor = UIColor.gray
                removeNotification(myEvent!)
            }

            
            saveContext()
            
            if let ed = self.eventCellDelegate {
                ed.updatedEvents()
            }
        } else {
            NSLog("No event defined on star tap")
        }
    }
    
    func saveContext() {
        do {
            try getContext().save()
        } catch {}
    }

}
