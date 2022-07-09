//
//  AboutCell.swift
//  hackertracker
//
//  Created by Seth Law on 8/5/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

protocol AboutCellDelegate: AnyObject {
    func followUrl(url: URL)
}

class AboutCell: UITableViewCell {
    @IBOutlet private var versionLabel: UIButton!
    var rick = 0
    weak var aboutDelegate: AboutCellDelegate?

    var versionTitle: String? {
        get { versionLabel.title(for: .normal) }
        set { versionLabel.setTitle(newValue, for: .normal) }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        backgroundColor = UIColor.backgroundGray
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        selectedBackgroundView = selectedView
    }

    @IBAction private func tappedTwitter(_ sender: Any) {
        if let sender = sender as? UIButton, let title = sender.titleLabel?.text, let aboutDelegate = aboutDelegate, let url = URL(string: "https://mobile.twitter.com/\(title.replacingOccurrences(of: "@", with: ""))") {
            aboutDelegate.followUrl(url: url)
        }
    }

    @IBAction private func tappedVersion(_ sender: Any) {
        if rick > 6, let delegate = aboutDelegate, let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ?autoplay=1") {
            delegate.followUrl(url: url)
            rick = 0
        } else {
            rick += 1
        }
    }
}
