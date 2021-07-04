//
//  HTSpeakersTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/6/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import CoreData
import UIKit

class HTSpeakersTableViewController: UITableViewController {
    typealias SpeakerSection = (letter: String, speakers: [HTSpeaker])

    var speakerSections: [SpeakerSection] = []

    var speakerToken: UpdateToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        speakerToken = FSConferenceDataController.shared.requestSpeakers(forConference: AnonymousSession.shared.currentConference) { result in
            switch result {
            case let .success(speakerList):
                self.speakerSections.removeAll()
                for l in "abcdefghijklmnopqrstuvwxyz" {
                    var speakers: [HTSpeaker] = []

                    for s in speakerList {
                        let fl = s.name.prefix(1).lowercased()
                        // NSLog("\(l) : \(fl)")
                        if fl == l.lowercased() {
                            speakers.append(s)
                        }
                    }
                    if speakers.count > 0 {
                        self.speakerSections.append((letter: l.uppercased(), speakers: speakers))
                    }
                }

                self.tableView.reloadData()
            case let .failure(error):
                NSLog("Update speakers table: \(error.localizedDescription)")
            }
        }
        reloadSpeakers()
        tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.middle, animated: false)
        clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return speakerSections.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speakerSections[section].speakers.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EventHeader") as? EventDateHeaderView ?? EventDateHeaderView(reuseIdentifier: "EventHeader")

        dateHeader.bind(speakerSections[section].letter)

        return dateHeader
    }

    override func sectionIndexTitles(for _: UITableView) -> [String]? {
        var ret: [String] = []
        for ss in speakerSections {
            if ss.speakers.count > 0 {
                ret.append(ss.letter)
            }
        }
        return ret
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "speakerCell", for: indexPath)

        cell.textLabel?.text = speakerSections[indexPath.section].speakers[indexPath.row].name

        return cell
    }

    func reloadSpeakers() {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        var speaker: HTSpeaker?

        if let selectedIndexPath = selectedIndexPath {
            speaker = speakerSections[selectedIndexPath.section].speakers[selectedIndexPath.row]
        }

        if let selectedIndexPath = selectedIndexPath,
           let speaker = speaker,
           selectedIndexPath.section < speakerSections.count,
           selectedIndexPath.row < speakerSections[selectedIndexPath.section].speakers.count
        {
            let newSpeaker = speakerSections[selectedIndexPath.section].speakers[selectedIndexPath.row]
            if newSpeaker.id == speaker.id {
                tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "speakerSegue" {
            let svc: HTSpeakerViewController

            if let destNav = segue.destination as? UINavigationController, let _svc = destNav.viewControllers.first as? HTSpeakerViewController {
                svc = _svc
            } else {
                svc = segue.destination as! HTSpeakerViewController
            }

            var ip: IndexPath
            if let sc = sender as? UITableViewCell {
                ip = tableView.indexPath(for: sc)! as IndexPath
            } else {
                ip = sender as! IndexPath
            }

            svc.speaker = speakerSections[ip.section].speakers[ip.row]
        }
    }
}
