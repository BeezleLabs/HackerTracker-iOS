//
//  HTHamburgerHeaderTableViewCell.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/28/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class HTHamburgerHeaderTableViewCell: UITableViewCell {
    @IBOutlet private var conferenceTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }
}
