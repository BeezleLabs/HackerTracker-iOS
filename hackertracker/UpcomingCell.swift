//
//  UpcomingCell.swift
//  hackertracker
//
//  Created by Seth Law on 7/16/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class UpcomingCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    
    var myEvent: Event?
    
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    func bind(event : Event) {
        myEvent = event
        
        title.text = event.title
        title.sizeToFit()
        title.numberOfLines = 0
        time.text = DateFormatterUtility.hourMinuteTimeFormatter.string(from: event.start_date!)
        
        self.contentView.layer.borderColor = UIColor(hexString: (event.event_type?.color!)!).cgColor
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 5
    }
}
