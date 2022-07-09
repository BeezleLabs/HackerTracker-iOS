//
//  CountDownCell.swift
//  hackertracker
//
//  Created by Seth W Law on 6/2/22.
//  Copyright © 2022 Beezle Labs. All rights reserved.
//

import UIKit

class CountDownCell: UITableViewCell {

    @IBOutlet weak var conLabel: UILabel!
    @IBOutlet weak var counter: UITextField!
    
    let dayColor = UIColor(hexString: "C16784")
    let hourColor = UIColor(hexString: "316295")
    let minColor = UIColor(hexString: "71CC98")
    let secColor = UIColor(hexString: "993C2A")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = .backgroundGray
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = .backgroundGray
        selectionStyle = .none
    }
    
    func apply(startDate: Date) {
        
    }
}
