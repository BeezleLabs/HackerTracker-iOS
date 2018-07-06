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
        titleLabel.text = DateFormatterUtility.yearMonthDayNoTimeZoneTimeFormatter.string(from: message.updated_at!)

        titleLabel.font = UIFont(name: "Bungee", size: 18)
        descriptionLabel.text = message.text
        descriptionLabel.font = UIFont(name: "Larsseit", size: 14)

    }


}
