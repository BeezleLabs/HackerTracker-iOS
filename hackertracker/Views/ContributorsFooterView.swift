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
    case version
}

protocol ContributorsFooterDelegate : class {
    func linkTapped(link : LinkType);
}

class ContributorsFooterView: UIView {
    
    weak var footerDelegate : ContributorsFooterDelegate?
    @IBOutlet weak var versionLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .backgroundGray

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(versionTapped))
        versionLabel.addGestureRecognizer(tapGesture)
        versionLabel.isUserInteractionEnabled = true
    }
    
    @objc func versionTapped() {
        footerDelegate?.linkTapped(link: .version)
    }
    
    @IBAction func sethLinkPressed(_ sender: Any) {
        footerDelegate?.linkTapped(link: .sethlaw)
    }
    
    @IBAction func chrisLinkPressed(_ sender: Any) {
        footerDelegate?.linkTapped(link: .chrismays94)
    }
    
    @IBAction func megLinkPressed(_ sender: Any) {
        footerDelegate?.linkTapped(link: .macerameg)
    }
    
}
