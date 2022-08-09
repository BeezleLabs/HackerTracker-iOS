//
//  HTMyScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/18/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import CoreData
import UIKit

class HTMyScheduleTableViewController: BaseScheduleTableViewController, HTConferenceTableViewControllerDelegate, EventDetailDelegate {
    var eventsToken: UpdateToken?
    var events: [UserEventModel] = []
    var selectedIndexPath: IndexPath?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if eventsToken == nil {
            self.setupTokens()
        }

        let tvb = navigationItem.titleView as! UIButton
        tvb.addTarget(self, action: #selector(displayConferencePicker(sender:)), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star.fill")
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let storyboard = self.storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
            self.selectedIndexPath = indexPath
            eventController.event = self.eventSections[indexPath.section].events[indexPath.row].event
            eventController.bookmark = self.eventSections[indexPath.section].events[indexPath.row].bookmark
            eventController.delegate = self
            self.navigationController?.pushViewController(eventController, animated: true)
        }
    }

    @objc func displayConferencePicker(sender: AnyObject) {
        let cvc = storyboard?.instantiateViewController(withIdentifier: "HTConferenceTableViewController") as! HTConferenceTableViewController
        cvc.delegate = self
        present(cvc, animated: false)
    }

    func didSelect(conference: ConferenceModel) {
        if let menuvc = self.navigationController?.parent as? HTHamburgerMenuViewController {
            menuvc.didSelectID(tabID: "Bookmarks")
            menuvc.backgroundTapped()
        }
    }

    func reloadEvents() {
        if let indexPath = self.selectedIndexPath {
            self.eventSections[indexPath.section].events[indexPath.row].bookmark.value.toggle()
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    func setupTokens() {
        self.eventsToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference, descending: false) { result in
            switch result {
            case .success(let eventsList):
                self.events.removeAll()
                self.eventSections.removeAll()
                let dfu = DateFormatterUtility.shared
                let conference = AnonymousSession.shared.currentConference
                if let start = dfu.yearMonthDayFormatter.date(from: conference.startDate), let end = dfu.yearMonthDayFormatter.date(from: conference.endDate) {
                    for day in dfu.getConferenceDates(start: start, end: end) {
                        var events: [UserEventModel] = []
                        let dayDate = dfu.yearMonthDayFormatter.date(from: day) ?? Date()
                        let range = dayDate...(dayDate.addingTimeInterval(86400))
                        for event in eventsList {
                            if event.bookmark.value, range.contains(event.event.begin) {
                                events.append(event)
                            } else {
                                // NSLog("\(e.event.title) not bookmarked")
                            }
                        }
                        if !events.isEmpty {
                            self.eventSections.append((date: day, events: events))
                        }
                    }
                    self.tableView.reloadData()
                }

            case .failure:
                // TODO: Properly log failure
                break
            }
        }
    }
}
