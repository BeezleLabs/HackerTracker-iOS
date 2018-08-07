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
    @IBOutlet weak var conSelected: UISwitch!
    
    var con: Conference?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if let conference = con {
            self.conSelected.setOn(conference.selected, animated: false)
        }
        
    }
    
    func setConference(conference: Conference) {
        self.con = conference
        self.name.text = self.con?.name
        let start = DateFormatterUtility.yearMonthDayFormatter.string(from: (self.con?.start_date)!)
        let end = DateFormatterUtility.yearMonthDayFormatter.string(from: (self.con?.end_date)!)
        self.dates.text = "\(start) - \(end)"
        self.conSelected.setOn((self.con?.selected)!, animated: false)
    }
    
    @IBAction func selectConference(_ sender: Any) {
        if let conference = con {
            conSelected.setOn(!conference.selected, animated: true)
            conference.selected = !conference.selected
            do {
                try getContext().save()
            } catch { }
        }
    }
    

}
