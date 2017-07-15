//
//  ContributersFooterView.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/14/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class ContributorsFooterView: UIView {

    @IBOutlet weak var contributorsHeaderLabel: UILabel!
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.frame = CGRect(x: 0, y: 0, width: 300, height: 460)
        backgroundColor = .backgroundGray

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let attributedCon = NSAttributedString(string: "CON", attributes: [NSFontAttributeName : UIFont.monospacedDigitSystemFont(ofSize: 17, weight: UIFontWeightBold), NSForegroundColorAttributeName : UIColor.white])
        let attributedTributor = NSAttributedString(string: "tributors", attributes: [NSFontAttributeName : UIFont.monospacedDigitSystemFont(ofSize: 17, weight: UIFontWeightLight), NSForegroundColorAttributeName : UIColor.white])
        
        let attributedContributer = NSMutableAttributedString(attributedString: attributedCon)
        attributedContributer.append(attributedTributor)
        
        contributorsHeaderLabel.attributedText = attributedContributer
    }
}
