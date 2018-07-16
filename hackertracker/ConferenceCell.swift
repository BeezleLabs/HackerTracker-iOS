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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if con != nil {
            self.conSelected.setOn((self.con?.selected)!, animated: false)
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
        NSLog("setting selected to \(!(self.con?.selected)!)")
        self.conSelected.setOn(!(self.con?.selected)!, animated: true)
        self.con?.selected = !(self.con?.selected)!
        do {
            try getContext().save()
        } catch {
            
        }
    }
    

}
