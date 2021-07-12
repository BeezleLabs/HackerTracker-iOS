//
//  HTSpeakersTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/6/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import CoreData
import Crashlytics
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
                for letter in "abcdefghijklmnopqrstuvwxyz" {
                    var speakers: [HTSpeaker] = []

                    for speaker in speakerList {
                        let firstLetter = speaker.name.prefix(1).lowercased()
                        // NSLog("\(l) : \(fl)")
                        if firstLetter == letter.lowercased() {
                            speakers.append(speaker)
                        }
                    }
                    if !speakers.isEmpty {
                        self.speakerSections.append((letter: letter.uppercased(), speakers: speakers))
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
        var titles: [String] = []
        for section in speakerSections where !section.speakers.isEmpty {
            titles.append(section.letter)
        }
        return titles
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
           selectedIndexPath.row < speakerSections[selectedIndexPath.section].speakers.count {
            let newSpeaker = speakerSections[selectedIndexPath.section].speakers[selectedIndexPath.row]
            if newSpeaker.id == speaker.id {
                tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "speakerSegue" {
            let destController: HTSpeakerViewController

            if let destNav = segue.destination as? UINavigationController, let controller = destNav.viewControllers.first as? HTSpeakerViewController {
                destController = controller
            } else {
                destController = segue.destination as! HTSpeakerViewController
            }

            var indexPath: IndexPath
            if let cell = sender as? UITableViewCell, let cellIndexPath = tableView.indexPath(for: cell) {
                indexPath = cellIndexPath
            } else if let senderIndexPath = sender as? IndexPath {
                indexPath = senderIndexPath
            } else {
                return
            }

            destController.speaker = speakerSections[indexPath.section].speakers[indexPath.row]
        }
    }
}
