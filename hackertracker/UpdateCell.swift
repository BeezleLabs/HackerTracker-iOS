//
//  UpdateCell.swift
//  hackertracker
//
//  Created by Chris Mays on 1/18/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class UpdateCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!

     @IBOutlet private var descriptionLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = .backgroundGray
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = .backgroundGray
        selectionStyle = .none
    }

    func bind(message: HTArticleModel) {
        let dfu = DateFormatterUtility.shared
        let date = dfu.monthDayTimeFormatter.string(from: message.updatedAt)

        titleLabel.text = message.name
        descriptionLabel.text = "[\(date)]: \(message.text)"
    }

    func bind(vendor: HTVendorModel) {
        titleLabel.text = vendor.name
        descriptionLabel.text = vendor.desc
    }

    func bind(title: String, desc: String) {
        titleLabel.text = title
        descriptionLabel.text = desc
    }
}
