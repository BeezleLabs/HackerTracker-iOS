//
//  EventDateHeaderView.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class EventDateHeaderView: UITableViewHeaderFooterView {

    
    private let dateLabel = UILabel()
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        dateLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        dateLabel.textAlignment = NSTextAlignment.center
        dateLabel.textColor = .white
        dateLabel.backgroundColor = UIColor.backgroundGray
        dateLabel.layer.borderColor = UIColor.darkGray.cgColor
        dateLabel.layer.borderWidth = 2.0
        dateLabel.layer.cornerRadius = 10
        dateLabel.font = UIFont(name: "Larsseit", size: 14)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func bindToDate(date : Date?)
    {
        if let date = date {
            if Calendar.current.isDateInYesterday(date) {
                dateLabel.text = "Yesterday"
            } else if Calendar.current.isDateInToday(date) {
                dateLabel.text = "Today"
            } else if Calendar.current.isDateInTomorrow(date) {
                dateLabel.text = "Tomorrow"
            } else {
                dateLabel.text = DateFormatterUtility.dayMonthDayOfWeekFormatter.string(from: date)
            }
        } else {
            dateLabel.text = "Unknown"
        }
    }
    

}
