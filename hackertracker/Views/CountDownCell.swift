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

        let cdv = UIHostingController(rootView: CountdownView(start: statDate))
        contentView.addSubview(cdv.view)
        cdv.view.translatesAutoresizingMaskIntoConstraints = false
        cdv.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cdv.view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        cdv.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        cdv.view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true

        cdv.view.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
