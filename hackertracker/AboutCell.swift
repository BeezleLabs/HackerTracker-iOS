//
//  AboutCell.swift
//  hackertracker
//
//  Created by Seth Law on 8/5/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import SwiftUI
import UIKit

class AboutCell: UITableViewCell {
    init() {
        super.init(style: .default, reuseIdentifier: "AboutViewCell")

        let abv = UIHostingController(rootView: AboutView())
        contentView.addSubview(abv.view)
        abv.view.translatesAutoresizingMaskIntoConstraints = false
        abv.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        abv.view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        abv.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        abv.view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true

        abv.view.backgroundColor = UIColor(red: 45.0 / 255.0, green: 45.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
