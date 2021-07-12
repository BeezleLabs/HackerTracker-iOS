//
//  HTHamburgerItemTableViewCell.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/28/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class HTHamburgerItemTableViewCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!
    var originalBackgroundColor: UIColor?

    var titleText: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var iconImage: UIImage? {
        get { iconView.image }
        set { iconView.image = newValue }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        originalBackgroundColor = self.backgroundColor
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: "#7389c1")
        selectedBackgroundView = backgroundView
    }
}
