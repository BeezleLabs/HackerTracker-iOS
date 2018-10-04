//
//  ConferenceCell.swift
//  hackertracker
//
//  Created by Seth Law on 7/9/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class ConferenceCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dates: UILabel!
    @IBOutlet weak var color: UIView!
    
    var con: Conference?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setConference(conference: Conference) {
        self.con = conference
        self.name.text = self.con?.name
        let dfu = DateFormatterUtility.shared
        let start = dfu.yearMonthDayFormatter.string(from: (self.con?.start_date)!)
        let end = dfu.yearMonthDayFormatter.string(from: (self.con?.end_date)!)
        self.dates.text = "\(start) - \(end)"
    }
    
    func selectConference(_ sender: Any) {
        if let conference = con {
            conference.selected = !conference.selected
            do {
                try getContext().save()
            } catch { }
        }
    }
    

}
