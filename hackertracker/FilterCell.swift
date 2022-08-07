//
//  FilterCell.swift
//  hackertracker
//
//  Created by Seth W Law on 8/6/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
    @IBOutlet private var filterDot: UIView!
    @IBOutlet private var filterLabel: UILabel!
    @IBOutlet private var filterCheck: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
