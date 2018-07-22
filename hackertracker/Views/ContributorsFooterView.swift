//
//  ContributersFooterView.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/14/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

enum LinkType {
    case chrismays94
    case imachumphries
    case sethlaw
    case macerameg
}

protocol ContributorsFooterDelegate : class {
    func linkTapped(link : LinkType);
}

class ContributorsFooterView: UIView {
    
    weak var footerDelegate : ContributorsFooterDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .backgroundGray

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func sethLinkPressed(_ sender: Any) {
        footerDelegate?.linkTapped(link: .sethlaw)
    }
    
    @IBAction func chrisLinkPressed(_ sender: Any) {
        footerDelegate?.linkTapped(link: .chrismays94)
    }
    
    @IBAction func benLinkPressed(_ sender: Any) {
        footerDelegate?.linkTapped(link: .imachumphries)
    }
    
    @IBAction func megLinkPressed(_ sender: Any) {
        footerDelegate?.linkTapped(link: .macerameg)
    }
    
}
