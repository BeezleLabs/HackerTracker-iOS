//
//  UpdateCell.swift
//  hackertracker
//
//  Created by Chris Mays on 1/18/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

public class UpdateCell : UITableViewCell {
    @IBOutlet var titleLabel: UILabel!

     @IBOutlet var descriptionLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .backgroundGray
        selectionStyle = .none
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = .backgroundGray
        selectionStyle = .none
    }

    func bind(message: Article) {
        let date = DateFormatterUtility.yearMonthDayNoTimeZoneTimeFormatter.string(from: message.updated_at!)

        titleLabel.text = message.name
        titleLabel.font = UIFont(name: "Bungee", size: 16)
        descriptionLabel.text = "[\(date)]: \(message.text!)"
        descriptionLabel.font = UIFont(name: "Larsseit", size: 14)

    }


}
