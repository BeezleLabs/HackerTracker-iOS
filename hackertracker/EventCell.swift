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
    @IBOutlet weak var color: UIView!
    @IBOutlet weak var et_label: UILabel!
    @IBOutlet weak var favorited: UIImageView!
    @IBOutlet weak var starttime: UILabel!
    @IBOutlet weak var et_dot: UIView!
    
    weak var eventCellDelegate : EventCellDelegate? 
    var userEvent: UserEventModel?
    
    var titleAttr = NSMutableAttributedString(string: "")
    
    
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
        et_dot.backgroundColor = oldColor
    }
    
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let oldColor = color.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        color.backgroundColor = oldColor
        et_dot.backgroundColor = oldColor
    }
    
    func bind(userEvent : UserEventModel) {
        self.userEvent = userEvent
        let event = userEvent.event
        let dfu = DateFormatterUtility.shared
        starttime.text = "\(dfu.shortDayOfMonthFormatter.string(from: event.begin))\n\(dfu.hourMinuteTimeFormatter.string(from: event.begin))\n\(dfu.timezoneFormatter.string(from: event.begin))"
        
        var i = 0
        var stext = ""
        for s in event.speakers {
            if i > 0 {
                stext = "\(stext), \(s.name)"
            } else {
                stext = "\(s.name)"
            }
            i = i + 1
        }
        
        titleAttr = NSMutableAttributedString(string: "")
        let titleAttrString = NSMutableAttributedString(string: event.title)
        let titleParStyle = NSMutableParagraphStyle()
        titleParStyle.alignment = .left
        titleAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: titleParStyle, range: NSRange(location: 0, length: (event.title as NSString).length))
        titleAttrString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .title3), range: NSRange(location: 0, length: (event.title as NSString).length))
        
        titleAttr.append(titleAttrString)
        
        if event.speakers.count > 0 {
            let spAttrString = NSMutableAttributedString(string: stext)
            let spParStyle = NSMutableParagraphStyle()
            spParStyle.alignment = .left
            spAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: spParStyle, range: NSRange(location: 0, length: (stext as NSString).length))
            spAttrString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSRange(location: 0, length: (stext as NSString).length))
            titleAttr.append(NSAttributedString(string:"\n"))
            titleAttr.append(spAttrString)
        }
        
        title.attributedText = titleAttr
        
        color.backgroundColor = UIColor(hexString: event.type.color)
        et_dot.backgroundColor = UIColor(hexString: event.type.color)
        et_dot.layer.cornerRadius = et_dot.frame.width/2
        et_dot.layer.masksToBounds = true
        //et_label.layer.borderColor = UIColor(hexString: event.type.color).cgColor
        //et_label.layer.borderWidth = 1.0
        //et_label.backgroundColor = UIColor(hexString: event.type.color)
        et_label.text = " \(event.type.name) "
        //et_label.layer.masksToBounds = true
        //et_label.layer.cornerRadius = 5
        
        subtitle.text = "\(event.location.name)"
        
        
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
        
    }
    
    @objc func tappedStar(sender: AnyObject) {
        if let e = userEvent {
            addBookmark(bookmark: e.bookmark, event: e.event, eventCell: self)
        } else {
            NSLog("No event defined on star tap")
        }
    }
}
