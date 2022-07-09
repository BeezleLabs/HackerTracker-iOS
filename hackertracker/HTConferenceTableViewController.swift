//
//  HTConferenceTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/8/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import CoreData
import UIKit

protocol HTConferenceTableViewControllerDelegate: AnyObject {
    func didSelect(conference: ConferenceModel)
}

class HTConferenceTableViewController: UITableViewController {
    var conferences: [ConferenceModel] = []
    var conferencesToken: UpdateToken?
    var selectCon: ConferenceModel?
    weak var delegate: HTConferenceTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if AnonymousSession.shared != nil {
            selectCon = AnonymousSession.shared.currentConference
        }
        self.loadConferences()
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
                // NSLog("already checked")
                guard let menuvc = self.navigationController?.parent as? HTHamburgerMenuViewController else {
                    self.dismiss(animated: false)
                    return
                }
                menuvc.backgroundTapped()
            } else {
                UserDefaults.standard.set(selectedConference.code, forKey: "conference")
                if AnonymousSession.shared != nil {
                    AnonymousSession.shared.currentConference = selectedConference
                    DateFormatterUtility.shared.update(identifier: selectedConference.timeZone)
                }
                delegate?.didSelect(conference: selectedConference)
                guard let menuvc = self.navigationController?.parent as? HTHamburgerMenuViewController else {
                    self.dismiss(animated: false)
                    return
                }
                menuvc.didSelectID(tabID: "Schedule")
                menuvc.backgroundTapped()
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conferenceCell", for: indexPath) as! ConferenceCell

        let conferenceModel = self.conferences[indexPath.row]
        cell.setConference(conference: conferenceModel)

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myCell = cell as! ConferenceCell
        let conferenceModel = self.conferences[indexPath.row]
        myCell.setConference(conference: conferenceModel)

        if let selectCon = selectCon, conferenceModel.code == selectCon.code {
            NSLog("Selected Con \(selectCon.code)")
            cell.setSelected(true, animated: true)
        } else {
            cell.setSelected(false, animated: true)
        }
    }

    func loadConferences() {
        conferencesToken = FSConferenceDataController.shared.requestConferences { result in
            switch result {
            case .success(let conferenceList):
                self.conferences = []
                for conference in conferenceList where !conference.hidden {
                    self.conferences.append(conference)
                }
                // TODO: Add a configuration setting to see past conferences or hidden conferences
                // self.conferences = conferenceList
                self.tableView.reloadData()
            case .failure:
                // NSLog("Error loading conferences")
                break
            }
        }
    }
}
