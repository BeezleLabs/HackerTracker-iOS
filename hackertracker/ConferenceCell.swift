//
//  ConferenceCell.swift
//  hackertracker
//
//  Created by Seth Law on 7/9/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit

class ConferenceCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dates: UILabel!
    @IBOutlet weak var color: UIView!
    
    var con: ConferenceModel?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setConference(conference: ConferenceModel) {
        self.con = conference
        self.name.text = self.con?.name
        //let dfu = DateFormatterUtility.shared
        //let start = dfu.yearMonthDayFormatter.string(from: (self.con?.startDate)!)
        //let end = dfu.yearMonthDayFormatter.string(from: (self.con?.endDate)!)
        let start = self.con?.startDate
        let end = self.con?.endDate
        self.dates.text = "\(start!) - \(end!)"
    }
    
    func selectConference(_ sender: Any) {
        /*if let conference = con {
            conference.selected = !conference.selected
            do {
                try getContext().save()
            } catch { }
        }*/
    }
    

}
