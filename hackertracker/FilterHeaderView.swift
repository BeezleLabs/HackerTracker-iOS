//
//  FilterHeaderView.swift
//  hackertracker
//
//  Created by Seth W Law on 8/6/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import UIKit

class FilterHeaderView: UITableViewHeaderFooterView {
    private let nameLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        nameLabel.textAlignment = NSTextAlignment.left
        nameLabel.textColor = .lightGray
        nameLabel.backgroundColor = .black
        nameLabel.layer.borderColor = UIColor.lightGray.cgColor
        nameLabel.layer.borderWidth = 0.5
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(_ headerLabel: String) {
        nameLabel.text = "    \(headerLabel)"
    }
}
