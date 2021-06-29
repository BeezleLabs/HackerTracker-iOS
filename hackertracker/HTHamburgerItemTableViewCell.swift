//
//  HTHamburgerItemTableViewCell.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/28/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class HTHamburgerItemTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    var originalBackgroundColor: UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()
        originalBackgroundColor = self.backgroundColor
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: "#7389c1")
        selectedBackgroundView = backgroundView
    }
}
