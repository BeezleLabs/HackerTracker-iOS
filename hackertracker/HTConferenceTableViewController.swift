//
//  HTConferenceTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/8/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTConferenceTableViewController: UITableViewController {
    
    var conferences: [Conference] = []
    var selectCon: Conference?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let c = DataRequestManager(managedContext: getContext()).getSelectedConference() {
            selectCon = c
        }
        self.loadConferences()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conferences.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let c = conferences[indexPath.row]
            if cell.accessoryType == .checkmark, c == selectCon {
                //NSLog("already checked")
            } else {
                selectConference(con: c)
                //cell.accessoryType = .checkmark
            }
        }
    }
    
    func selectConference(con: Conference) {
        for i in 0...(conferences.count-1) {
            let c = conferences[i]
            let indexPath = IndexPath(row: i, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! ConferenceCell
            if c == con {
                c.selected = true
                //print("trying to update tz to \(c.timezone!)")
                DateFormatterUtility.shared.update(identifier: c.timezone ?? "America/Los_Angeles")
                cell.accessoryType = .checkmark
                cell.color.isHidden = false
            } else {
                c.selected = false
                cell.accessoryType = .none
                cell.color.isHidden = true
            }
        }
        do {
            try getContext().save()
        } catch {
            NSLog("couldn't save context")
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conferenceCell", for: indexPath) as! ConferenceCell

        var c: Conference
        
        c = self.conferences[indexPath.row]
        cell.setConference(conference: c)
        
        if let s = selectCon, c == s {
            cell.accessoryType = .checkmark
            cell.color.isHidden = false
        } else {
            cell.accessoryType = .none
            cell.color.isHidden = true
        }

        return cell
    }
    
    func loadConferences() {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Conference")
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        
        conferences = try! getContext().fetch(fr) as! [Conference]
    }

}
