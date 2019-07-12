//
//  HTConferenceTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/8/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

protocol HTConferenceTableViewControllerDelegate : class {
    func didSelect(conference: ConferenceModel)
}

class HTConferenceTableViewController: UITableViewController {
    
    var conferences: [ConferenceModel] = []
    var conferencesToken : UpdateToken<ConferenceModel>?
    var selectCon: ConferenceModel?
    weak var delegate : HTConferenceTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AnonymousSession.shared != nil {
            selectCon = AnonymousSession.shared.currentConference
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
            let selectedConference = conferences[indexPath.row]
            if cell.accessoryType == .checkmark, selectedConference.code == selectCon?.code {
                //NSLog("already checked")
            } else {
                UserDefaults.standard.set(selectedConference.code, forKey: "conference")
                if AnonymousSession.shared != nil {
                    AnonymousSession.shared.currentConference = selectedConference
                }
                delegate?.didSelect(conference: selectedConference)
                guard let menuvc = self.navigationController?.parent as? HTHamburgerMenuViewController else {
                    NSLog("Couldn't find parent view controller")
                    return
                }
                menuvc.didSelectID(tabID: "Home")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conferenceCell", for: indexPath) as! ConferenceCell
        
        let conferenceModel = self.conferences[indexPath.row]
        cell.setConference(conference: conferenceModel)
        
        if let selectCon = selectCon, conferenceModel.code == selectCon.code {
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
                self.tableView.reloadData()
            case .failure(let _):
                NSLog("")
            }
        }
        
    }

}
