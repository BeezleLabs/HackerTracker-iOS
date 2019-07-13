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
    var userEvent: UserEventModel?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
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

    func bind(userEvent : UserEventModel) {
        self.userEvent = userEvent
        let event = userEvent.event
        var eventTime = "TBD"
        let dfu = DateFormatterUtility.shared
        eventTime = dfu.dayOfWeekTimeFormatter.string(from:event.beginDate) + "-"
        if Calendar.current.isDate(event.endDate, inSameDayAs: event.beginDate) {
            eventTime = eventTime + dfu.hourMinuteTimeFormatter.string(from: event.endDate)
        } else {
            eventTime = eventTime + dfu.dayOfWeekTimeFormatter.string(from: event.endDate)
        }

        
        title.text = event.title

        color.backgroundColor = UIColor(hexString: (event.type.color))
        et_label.layer.borderColor = UIColor(hexString: event.type.color).cgColor
        et_label.layer.borderWidth = 1.0
        et_label.backgroundColor = UIColor(hexString: event.type.color)
        et_label.text = " \(event.type.name) "
        et_label.layer.masksToBounds = true
        et_label.layer.cornerRadius = 5
            
        subtitle.text = "| \(event.location.name)"

        
        if userEvent.bookmark.value {
            favorited.image = #imageLiteral(resourceName: "saved-active").withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            favorited.tintColor = UIColor.white
        } else {
            favorited.image = #imageLiteral(resourceName: "saved-inactive").withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            favorited.tintColor = UIColor.gray
        }

        
        let tr = UITapGestureRecognizer(target: self, action: #selector(tappedStar(sender:)))
        tr.delegate = self
        favorited.addGestureRecognizer(tr)
        favorited.isUserInteractionEnabled = true

        time.text = eventTime
    }
    
    @objc func tappedStar(sender: AnyObject) {
        if let e = userEvent {
            FSConferenceDataController.shared.setFavorite(forConference: AnonymousSession.shared.currentConference, eventModel: e.event, isFavorite: !e.bookmark.value, session: AnonymousSession.shared) { (error) in
           
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
