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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conferenceCell", for: indexPath) as! ConferenceCell

        var c: Conference
        
        c = self.conferences[indexPath.row]
        cell.setConference(conference: c)
        
        if conferences.count == 1 {
            cell.conSelected.isEnabled = false
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
