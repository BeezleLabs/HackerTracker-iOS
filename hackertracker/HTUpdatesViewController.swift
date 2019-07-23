//
//  HTUpdatesViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class HTUpdatesViewController: UIViewController, EventDetailDelegate, EventCellDelegate {

    @IBOutlet weak var updatesTableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var trailingImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var skullBackground: UIImageView!
    @IBOutlet weak var conName: UILabel!

    var messages: [HTArticleModel] = []
    var eventSections: [String] = ["News", "Up Next On Schedule", "Up Next", "Live Now", "About"]
    var starred: [UserEventModel] = []
    var upcoming: [UserEventModel] = []
    var liveNow: [UserEventModel] = []
    var data = NSMutableData()
    var eventsToken : UpdateToken?
    var allEvents: [UserEventModel] = []
    var allArticles: [HTArticleModel] = []
    var starredEventsToken : UpdateToken?
    var liveEventsToken : UpdateToken?
    var articlesToken : UpdateToken?
    var lastContentOffset: CGPoint?
    var rick: Int = 0

    var footer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatesTableView.rowHeight = UITableView.automaticDimension
        updatesTableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        updatesTableView.register(UINib.init(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        updatesTableView.register(UINib.init(nibName: "AboutCell", bundle: nil), forCellReuseIdentifier: "AboutCell")
        
        updatesTableView.delegate = self
        updatesTableView.dataSource = self
        updatesTableView.backgroundColor = UIColor.clear
        updatesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.title = AnonymousSession.shared.currentConference.name
        
        eventsToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference!, descending: false) { (result) in
            switch result {
            case .success(let eventList):
                self.allEvents = eventList
                self.reloadEvents()
            case .failure(let _):
                NSLog("")
            }
        }
        
        articlesToken = FSConferenceDataController.shared.requestArticles(forConference: AnonymousSession.shared.currentConference, descending: true) { (result) in
            switch result {
            case .success(let articles):
                self.allArticles = articles
                self.reloadArticles()
            case .failure(_):
                NSLog("")
            }
        }
        //self.reloadEvents()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatesTableView.tableFooterView = self.footer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isViewLoaded && !animated  {
            reloadEvents()

            if let lastContentOffset = lastContentOffset {
                updatesTableView.contentOffset = lastContentOffset
                updatesTableView.layoutIfNeeded()
            }
        }
    }
    
    func reloadArticles() {
        self.messages = []
        for a in allArticles {
            if self.messages.count > 1 {
                break
            } else {
                self.messages.append(a)
            }
        }
        self.updatesTableView.reloadData()
    }

    func reloadEvents() {
        let curTime = Date()
        // To check test data on home screen (set to mid-layerone)
        //let curTime = DateFormatterUtility.shared.iso8601Formatter.date(from: "2019-05-25T11:43:01.000-0600")!

        self.starred = []
        starredLoop: for e in allEvents {
            if self.starred.count > 2 {
                break starredLoop
            } else {
                if  e.event.beginDate > curTime, e.bookmark.value {
                    self.starred.append(e)
                }
            }
        }
        
        self.upcoming = []
        upcomingLoop: for e in allEvents {
            if self.upcoming.count > 2 {
                break upcomingLoop
            } else {
                if e.event.beginDate > curTime {
                    self.upcoming.append(e)
                }
            }
        }
        
        self.liveNow = []
        liveLoop: for e in allEvents {
            let range = e.event.beginDate...e.event.endDate
            if range.contains(curTime) {
                self.liveNow.append(e)
            }
        }
        
        self.updatesTableView.reloadData()
        
    }
    
    func updatedEvents() {
        self.reloadEvents()
        updatesTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        lastContentOffset = self.updatesTableView.contentOffset
        if segue.identifier == "eventDetailSegue" {
            let dv : HTEventDetailViewController

            if let destinationNav = segue.destination as? UINavigationController, let _dv = destinationNav.viewControllers.first as? HTEventDetailViewController {
                dv = _dv
            } else {
                dv = segue.destination as! HTEventDetailViewController
            }

            if let indexPath = sender as? IndexPath {
                if indexPath.section == 1 {
                    dv.event = self.starred[indexPath.row].event
                    dv.bookmark = self.starred[indexPath.row].bookmark
                } else if indexPath.section == 2 {
                    dv.event = self.upcoming[indexPath.row].event
                    dv.bookmark = self.upcoming[indexPath.row].bookmark
                } else if indexPath.section == 3 {
                    dv.event = self.liveNow[indexPath.row].event
                    dv.bookmark = self.liveNow[indexPath.row].bookmark
                }
            }

            dv.delegate = self
        }
    }
}

extension HTUpdatesViewController : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventSections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
            if messages.count > 0 {
                cell.bind(message: messages[indexPath.row])
            } else {
                cell.bind(title: "No News is Good News", desc: "Or maybe you just need to update your database")
            }
            return cell
        } else if indexPath.section == 1 {
            if starred.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
                let event = starred[indexPath.row]
                cell.bind(userEvent: event)
                cell.eventCellDelegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
                cell.bind(title: "No Events", desc: "Explore #hackertracker and maybe you will find something interesting to attend. Tap the star to have the event show up here on the home screen and in your schedule of events.")
                return cell
            }

        } else if indexPath.section == 2 {
            if upcoming.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
                let event = upcoming[indexPath.row]
                cell.bind(userEvent: event)
                cell.eventCellDelegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
                cell.bind(title: "No Events", desc: "Is the conference cancelled?")
                return cell
            }

        } else if indexPath.section == 3 {
            if liveNow.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
                let event = liveNow[indexPath.row]
                cell.bind(userEvent: event)
                cell.eventCellDelegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
                cell.bind(title: "No Live Events", desc: "Nothing is going on right now, maybe try again later?")
                return cell
            }
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath) as! AboutCell
            if let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                cell.versionLabel.setTitle("Hackertracker iOS v\(v) (\(b))", for: UIControl.State.normal)
            }
            cell.aboutDelegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()

        let headerLabel = UILabel(frame: CGRect(x: 25, y: 0, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont.preferredFont(forTextStyle: .body)
        headerLabel.textColor = UIColor.lightGray
        headerLabel.text = eventSections[section].uppercased()
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if messages.count > 0 {
                return messages.count
            } else {
                return 1
            }
            
        } else if section == 1 {
            if starred.count > 0 {
                return starred.count
            } else {
                return 1
            }
        } else if section == 2 {
            if upcoming.count > 0 {
                return upcoming.count
            } else {
                return 1
            }
        } else if section == 3 {
            if liveNow.count > 0 {
                return liveNow.count
            } else {
                return 1
            }
        } else if section == 4 {
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ( indexPath.section == 1 && starred.count > 0 )
            || ( indexPath.section == 2 && upcoming.count > 0 )
            || ( indexPath.section == 3 && liveNow.count > 0 ) {
            if let storyboard = self.storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
                if indexPath.section == 1 {
                    eventController.event = self.starred[indexPath.row].event
                    eventController.bookmark = self.starred[indexPath.row].bookmark
                } else if indexPath.section == 2 {
                    eventController.event = self.upcoming[indexPath.row].event
                    eventController.bookmark = self.upcoming[indexPath.row].bookmark
                } else if indexPath.section == 3 {
                    eventController.event = self.liveNow[indexPath.row].event
                    eventController.bookmark = self.liveNow[indexPath.row].bookmark
                }
                self.navigationController?.pushViewController(eventController, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension HTUpdatesViewController: AboutCellDelegate {
    func followUrl(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = UIColor.backgroundGray
        safariVC.preferredControlTintColor = UIColor.white
        present(safariVC, animated: true, completion: nil)
    }
}
