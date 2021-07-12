//
//  ScheduleEmptyStateView.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/13/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class ScheduleEmptyStateView: UIView {
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var descriptionIcon: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.backgroundGray
    }

    func bind(description: String, image: UIImage) {
        backgroundColor = UIColor.backgroundGray
        descriptionLabel.text = description
        descriptionIcon.image = image
    }
}
