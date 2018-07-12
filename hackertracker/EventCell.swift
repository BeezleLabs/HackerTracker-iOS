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
    @IBOutlet weak var et_label: UILabel!
    @IBOutlet weak var favorited: UIImageView!
    
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
    }

    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let oldColor = color.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        color.backgroundColor = oldColor
    }

    func bind(event : Event) {
        myEvent = event
        let eventTime = DateFormatterUtility.hourMinuteTimeFormatter.string(from:event.start_date as! Date) + "-" + DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.end_date as! Date)
        
        title.text = event.title

        color.backgroundColor = UIColor(hexString: (event.event_type?.color!)!)
        
        if event.location?.id == 0 {
            subtitle.text = "Location in description"
        } else {
            subtitle.text = event.location?.name
        }
        
        et_label.backgroundColor = UIColor(hexString: (event.event_type?.color!)!)
        et_label.text = " \((event.event_type?.name!)!) "
        et_label.layer.masksToBounds = true
        et_label.layer.cornerRadius = 5
        favorited.tintColor = UIColor.white
        
        if event.starred {
            favorited.image = #imageLiteral(resourceName: "saved-active").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            favorited.tintColor = UIColor.yellow
        } else {
            favorited.image = #imageLiteral(resourceName: "saved-inactive").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            favorited.tintColor = UIColor.white
        }
        
        let tr = UITapGestureRecognizer(target: self, action: #selector(tappedStar(sender:)))
        tr.delegate = self
        favorited.addGestureRecognizer(tr)
        favorited.isUserInteractionEnabled = true

        time.text = eventTime
    }
    
    @objc func tappedStar(sender: AnyObject) {
        if myEvent != nil {
            myEvent?.starred = !(myEvent?.starred)!
            if (myEvent?.starred)! {
                favorited.image = #imageLiteral(resourceName: "saved-active").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                favorited.tintColor = UIColor.yellow
            } else {
                favorited.image = #imageLiteral(resourceName: "saved-inactive").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                favorited.tintColor = UIColor.white
            }
            do {
                try getContext().save()
            } catch {}
        } else {
            NSLog("No event defined on star tap")
        }
    }

}
