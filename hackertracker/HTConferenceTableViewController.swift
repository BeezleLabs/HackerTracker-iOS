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
    
    var conferences: [ConferenceModel] = []
    var conferencesToken : UpdateToken<ConferenceModel>?
    var selectCon: ConferenceModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            if cell.accessoryType == .checkmark, c.code == selectCon?.code {
                //NSLog("already checked")
            } else {
                selectConference(code: c.code)
            }
        }
    }
    
    func selectConference(code: String) {

        
        for i in 0...(conferences.count-1) {
            let c = conferences[i]
            let indexPath = IndexPath(row: i, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! ConferenceCell
            if c.code == code {
                DateFormatterUtility.shared.update(identifier: c.tz )
                cell.accessoryType = .checkmark
                cell.color.isHidden = false
            } else {
                cell.accessoryType = .none
                cell.color.isHidden = true
            }
        }

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conferenceCell", for: indexPath) as! ConferenceCell

        var c: ConferenceModel
        
        c = self.conferences[indexPath.row]
        cell.setConference(conference: c)
        
        if let s = selectCon, c.code == s.code {
            cell.accessoryType = .checkmark
            cell.color.isHidden = false
        } else {
            cell.accessoryType = .none
            cell.color.isHidden = true
        }

        return cell
    }
    
    func loadConferences() {
        
        conferencesToken = FSConferenceDataController.shared.requestConferences { (result) in
            switch result {
            case .success(let conferenceList):
                self.conferences.append(contentsOf: conferenceList)
                NSLog("Total conferences \(self.conferences.count)")
                self.tableView.reloadData()
                if let c = UserDefaults.standard.string(forKey: "conference") {
                    self.selectConference(code: c)
                }
            case .failure(let _):
                NSLog("")
            }
        }
        
    }

}
