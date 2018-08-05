//
//  AboutCell.swift
//  hackertracker
//
//  Created by Seth Law on 8/5/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

protocol AboutCellDelegate: class {
    func followUrl(url: URL)
}

class AboutCell: UITableViewCell {
    
    @IBOutlet weak var versionLabel: UIButton!
    var rick = 0
    weak var aboutDelegate: AboutCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        backgroundColor = UIColor.backgroundGray
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        selectedBackgroundView = selectedView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tappedTwitter(_ sender: Any) {
        
        if let s = sender as? UIButton, let t = s.titleLabel?.text, let d = aboutDelegate, let url = URL(string: "https://mobile.twitter.com/\(t.replacingOccurrences(of: "@", with: ""))") {
            d.followUrl(url: url)
        }
    }

    @IBAction func tappedVersion(_ sender: Any) {
        if rick > 6, let d = aboutDelegate, let url = URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0?autoplay=1") {
            d.followUrl(url: url)
            rick = 0
        } else {
            rick = rick + 1
        }
    }
}
