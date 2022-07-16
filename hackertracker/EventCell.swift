//
//  EventCell.swift
//  hackertracker
//
//  Created by Chris Mays on 1/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

protocol EventCellDelegate: AnyObject {
    func updatedEvents()
}

class EventCell: UITableViewCell {
    @IBOutlet private var title: UILabel!
    @IBOutlet private var subtitle: UILabel!
    @IBOutlet private var color: UIView!
    @IBOutlet private var etLabel: UILabel!
    @IBOutlet private var favorited: UIImageView!
    @IBOutlet private var starttime: UILabel!
    @IBOutlet private var etDot: UIView!

    weak var eventCellDelegate: EventCellDelegate?
    var userEvent: UserEventModel?

    var titleAttr = NSMutableAttributedString(string: "")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        backgroundColor = UIColor.backgroundGray
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let oldColor = color.backgroundColor
        super.setSelected(selected, animated: animated)
        color.backgroundColor = oldColor
        etDot.backgroundColor = oldColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let oldColor = color.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        color.backgroundColor = oldColor
        etDot.backgroundColor = oldColor
    }

    func bind(userEvent: UserEventModel) {
        self.userEvent = userEvent
        let event = userEvent.event
        let dfu = DateFormatterUtility.shared
        starttime.text = "\(dfu.shortDayOfMonthFormatter.string(from: event.begin))\n\(dfu.hourMinuteTimeFormatter.string(from: event.begin))\n\(dfu.timezoneFormatter.string(from: event.begin))"

        let speakers = event.speakers.map(\.name).joined(separator: ", ")

        titleAttr = NSMutableAttributedString(string: "")
        let titleAttrString = NSMutableAttributedString(string: event.title, attributes: [
            .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
            .font: UIFont.preferredFont(forTextStyle: .title3),
        ])
        titleAttr.append(titleAttrString)

        if !event.speakers.isEmpty {
            let spAttrString = NSMutableAttributedString(string: speakers, attributes: [
                .paragraphStyle: NSParagraphStyle.leftAlignedParagraph,
                .font: UIFont.preferredFont(forTextStyle: .body),
            ])
            titleAttr.append(NSAttributedString(string: "\n"))
            titleAttr.append(spAttrString)
        }

        title.attributedText = titleAttr

        color.backgroundColor = UIColor(hexString: event.type.color)
        etDot.backgroundColor = UIColor(hexString: event.type.color)
        etDot.layer.cornerRadius = etDot.frame.width / 2
        etDot.layer.masksToBounds = true
        // etLabel.layer.borderColor = UIColor(hexString: event.type.color).cgColor
        // etLabel.layer.borderWidth = 1.0
        // etLabel.backgroundColor = UIColor(hexString: event.type.color)
        etLabel.text = " \(event.type.name) "
        // etLabel.layer.masksToBounds = true
        // etLabel.layer.cornerRadius = 5

        subtitle.text = "\(event.location.name)"

        if userEvent.bookmark.value {
            favorited.image = UIImage(systemName: "star.fill")
            favorited.tintColor = UIColor.white
        } else {
            favorited.image = UIImage(systemName: "star")
            favorited.tintColor = UIColor.gray
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedStar(sender:)))
        tapGesture.delegate = self
        favorited.addGestureRecognizer(tapGesture)
        favorited.isUserInteractionEnabled = true
    }

    @objc func tappedStar(sender: AnyObject) {
        if let userEvent = userEvent {
            addBookmark(bookmark: userEvent.bookmark, event: userEvent.event, eventCell: self)
        } else {
            NSLog("No event defined on star tap")
        }
    }
}
