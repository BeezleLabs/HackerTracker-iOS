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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .backgroundGray
        selectionStyle = .none
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = .backgroundGray
        selectionStyle = .none
    }

    func bind(message: HTArticleModel) {
        let dfu = DateFormatterUtility.shared
        let date = dfu.yearMonthDayNoTimeZoneTimeFormatter.string(from: message.updated_at)

        titleLabel.text = message.name
        descriptionLabel.text = "[\(date)]: \(message.text)"

    }
    
    func bind(vendor: Vendor) {
        
        if let n = vendor.name, let d = vendor.desc {
            titleLabel.text = n
            descriptionLabel.text = d
        }
        
    }
    
    func bind(title: String, desc: String) {
        titleLabel.text = title
        descriptionLabel.text = desc
    }


}
