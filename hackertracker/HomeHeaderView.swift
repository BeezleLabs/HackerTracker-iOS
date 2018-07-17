//
//  HomeHeaderView.swift
//  hackertracker
//
//  Created by Seth Law on 7/16/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class HomeHeaderView: UITableViewHeaderFooterView {
    let headerLabel = UILabel()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        headerLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        headerLabel.textAlignment = .left
        headerLabel.textColor = .white
        headerLabel.backgroundColor = .black
        headerLabel.font = UIFont(name: "Larsseit", size: 14)
        self.backgroundView?.backgroundColor = .black
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
