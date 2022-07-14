//
//  CountDownCell.swift
//  hackertracker
//
//  Created by Seth W Law on 6/2/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import SwiftUI
import UIKit

class CountDownCell: UITableViewCell {
    init(statDate: Date) {
        super.init(style: .default, reuseIdentifier: "CountDownViewCell")

        let cv = UIHostingController(rootView: Countdown(start: statDate))
        contentView.addSubview(cv.view)
        cv.view.translatesAutoresizingMaskIntoConstraints = false
        cv.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cv.view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        cv.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        cv.view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true

        cv.view.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
