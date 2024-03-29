//
//  HTUpdatesViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import CoreData
import SafariServices
import SwiftUI
import UIKit

class HTUpdatesViewController: UIViewController, EventDetailDelegate, EventCellDelegate, HTConferenceTableViewControllerDelegate {
    @IBOutlet private var updatesTableView: UITableView!
    @IBOutlet private var backgroundImage: UIImageView!

    @IBOutlet private var trailingImageConstraint: NSLayoutConstraint!
    @IBOutlet private var skullBackground: UIImageView!
    @IBOutlet private var conName: UILabel!

    var messages: [HTArticleModel] = []
    var curDate = Date()
    var eventSections: [String] = (Date() < AnonymousSession.shared.currentConference.startTimestamp) ? ["Count Down", "News", "Upcoming Bookmarks", "Live Now", "About"] : ["News", "Upcoming Bookmarks", "Live Now", "About"]
    var starred: [UserEventModel] = []
    var liveNow: [UserEventModel] = []
    var data = NSMutableData()
    var eventsToken: UpdateToken?
    var allEvents: [UserEventModel] = []
    var allArticles: [HTArticleModel] = []
    var starredEventsToken: UpdateToken?
    var liveEventsToken: UpdateToken?
    var articlesToken: UpdateToken?
    var lastContentOffset: CGPoint?
    var rick: Int = 0
    var footer: UIView! // swiftlint:disable:this implicitly_unwrapped_optional

    override func viewDidLoad() {
        super.viewDidLoad()

        updatesTableView.rowHeight = UITableView.automaticDimension
        updatesTableView.estimatedRowHeight = 75
        updatesTableView.sectionHeaderHeight = UITableView.automaticDimension
        updatesTableView.estimatedSectionHeaderHeight = 30
        updatesTableView.register(UINib(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        updatesTableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        updatesTableView.register(UINib(nibName: "AboutCell", bundle: nil), forCellReuseIdentifier: "AboutCell")

        updatesTableView.delegate = self
        updatesTableView.dataSource = self
        updatesTableView.backgroundColor = UIColor.clear
        updatesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let titleViewButton = UIButton(type: .system)
        titleViewButton.setTitleColor(UIColor.white, for: .normal)
        titleViewButton.setTitle("\(AnonymousSession.shared.currentConference.name)", for: .normal)
        titleViewButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        titleViewButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        titleViewButton.imageView?.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
        titleViewButton.addTarget(self, action: #selector(displayConferencePicker(sender:)), for: .touchUpInside)
        titleViewButton.semanticContentAttribute = .forceRightToLeft
        navigationItem.titleView = titleViewButton

        title = AnonymousSession.shared.currentConference.name

        eventsToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference, descending: false) { result in
            switch result {
            case let .success(eventList):
                self.allEvents = eventList
                self.reloadEvents()
            case .failure:
                // TODO: Properly log failure
                break
            }
        }

        articlesToken = FSConferenceDataController.shared.requestArticles(forConference: AnonymousSession.shared.currentConference, descending: true) { result in
            switch result {
            case let .success(articles):
                self.allArticles = articles
                self.reloadArticles()
            case .failure:
                // TODO: Properly log failure
                break
            }
        }

        updatesTableView.layoutIfNeeded()
    }

    @objc func displayConferencePicker(sender _: AnyObject) {
        let cvc = storyboard?.instantiateViewController(withIdentifier: "HTConferenceTableViewController") as! HTConferenceTableViewController
        cvc.delegate = self
        present(cvc, animated: false)
    }

    func didSelect(conference: ConferenceModel) {
        if let menuvc = self.navigationController?.parent as? HTHamburgerMenuViewController {
            menuvc.didSelectID(tabID: "Information")
            menuvc.backgroundTapped()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatesTableView.tableFooterView = footer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        curDate = Date()

        if isViewLoaded, !animated {
            reloadEvents()

            if let lastContentOffset = lastContentOffset {
                updatesTableView.contentOffset = lastContentOffset
                updatesTableView.layoutIfNeeded()
            }
        }
        updatesTableView.layoutIfNeeded()
    }

    func reloadArticles() {
        messages = []
        for article in allArticles {
            if messages.count > 1 {
                break
            } else {
                messages.append(article)
            }
        }
        updatesTableView.reloadData()
    }

    func reloadEvents() {
        let curTime = Date()
        // To check test data on home screen (set to mid-layerone)
        // let curTime = DateFormatterUtility.shared.iso8601Formatter.date(from: "2019-05-25T11:43:01.000-0600")!

        starred = []
        starredLoop: for event in allEvents {
            if starred.count > 4 {
                break starredLoop
            } else {
                if event.event.begin > curTime, event.bookmark.value {
                    starred.append(event)
                }
            }
        }

        liveNow = []
        for event in allEvents where event.event.begin < event.event.end {
            let range = event.event.begin ... event.event.end
            if range.contains(curTime) {
                self.liveNow.append(event)
            }
        }

        updatesTableView.reloadData()
    }

    func updatedEvents() {
        reloadEvents()
        updatesTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        lastContentOffset = updatesTableView.contentOffset
        if segue.identifier == "eventDetailSegue" {
            let destController: HTEventDetailViewController

            if let destinationNav = segue.destination as? UINavigationController, let controller = destinationNav.viewControllers.first as? HTEventDetailViewController {
                destController = controller
            } else {
                destController = segue.destination as! HTEventDetailViewController
            }

            if let indexPath = sender as? IndexPath {
                if indexPath.section == 1 {
                    destController.event = starred[indexPath.row].event
                    destController.bookmark = starred[indexPath.row].bookmark
                } else if indexPath.section == 2 {
                    destController.event = liveNow[indexPath.row].event
                    destController.bookmark = liveNow[indexPath.row].bookmark
                }
            }
            destController.delegate = self
        }
    }
}

extension HTUpdatesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return eventSections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // swiftlint:disable:this cyclomatic_complexity
        if curDate > AnonymousSession.shared.currentConference.startTimestamp {
            switch indexPath.section {
            case 0:
                return getUpdateCell(tableView: tableView, indexPath: indexPath)
            case 1:
                return getMyEventsCell(tableView: tableView, indexPath: indexPath)
            case 2:
                return getLiveEventsCell(tableView: tableView, indexPath: indexPath)
            case 3:
                return getAboutCell(tableView: tableView, indexPath: indexPath)
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
                return cell
            }
        } else {
            switch indexPath.section {
            case 0:
                return getCountdownCell()
            case 1:
                return getUpdateCell(tableView: tableView, indexPath: indexPath)
            case 2:
                return getMyEventsCell(tableView: tableView, indexPath: indexPath)
            case 3:
                return getLiveEventsCell(tableView: tableView, indexPath: indexPath)
            case 4:
                return getAboutCell(tableView: tableView, indexPath: indexPath)
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
                return cell
            }
        }
    }

    private func getCountdownCell() -> CountDownCell {
        return CountDownCell(statDate: AnonymousSession.shared.currentConference.startTimestamp)
    }

    private func getUpdateCell(tableView: UITableView, indexPath: IndexPath) -> UpdateCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
        if !messages.isEmpty {
            cell.bind(message: messages[indexPath.row])
        } else {
            cell.bind(title: "No News is Good News", desc: "The #hackertracker team has no updates for you right now.")
        }
        return cell
    }

    private func getMyEventsCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if !starred.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            let event = starred[indexPath.row]
            cell.bind(userEvent: event)
            cell.eventCellDelegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
            cell.bind(title: "No Events", desc: "Explore #hackertracker to find something to attend. Tap the star and the event will display here on the home screen and in your bookmarked events.")
            return cell
        }
    }

    private func getLiveEventsCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if !liveNow.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            let event = liveNow[indexPath.row]
            cell.bind(userEvent: event)
            cell.eventCellDelegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
            cell.bind(title: "No Live Events", desc: "No ongoing events, try again later.")
            return cell
        }
    }

    private func getAboutCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return AboutCell()
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UIButton()
        headerLabel.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        headerLabel.setTitleColor(.lightGray, for: .normal)
        // headerLabel.titleLabel!.textColor = UIColor.lightGray
        headerLabel.titleLabel?.numberOfLines = 0
        headerLabel.titleLabel?.minimumScaleFactor = 0.5
        headerLabel.titleLabel?.lineBreakMode = .byTruncatingTail

        headerLabel.contentHorizontalAlignment = .left
        headerLabel.contentVerticalAlignment = .center
        headerLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 5)
        headerLabel.setTitle(eventSections[section].uppercased(), for: .normal)
        headerLabel.isUserInteractionEnabled = false

        // headerLabel.padding =

        headerLabel.titleLabel?.sizeToFit()
        headerLabel.sizeToFit()

        return headerLabel
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int { // swiftlint:disable:this cyclomatic_complexity
        if curDate > AnonymousSession.shared.currentConference.startTimestamp {
            switch section {
            case 0:
                return (!messages.isEmpty) ? messages.count : 1
            case 1:
                return (!starred.isEmpty) ? starred.count : 1
            case 2:
                return (!liveNow.isEmpty) ? liveNow.count : 1
            case 3:
                return 1
            default:
                return 0
            }
        } else {
            switch section {
            case 0:
                return 1
            case 1:
                return (!messages.isEmpty) ? messages.count : 1
            case 2:
                return (!starred.isEmpty) ? starred.count : 1
            case 3:
                return (!liveNow.isEmpty) ? liveNow.count : 1
            case 4:
                return 1
            default:
                return 0
            }
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        var offset = 0
        if curDate < AnonymousSession.shared.currentConference.startTimestamp {
            offset = 1
        }

        if (indexPath.section == (offset + 1) && !starred.isEmpty) || (indexPath.section == (offset + 2) && !liveNow.isEmpty) {
            if let storyboard = storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
                if indexPath.section == (offset + 1) {
                    eventController.event = starred[indexPath.row].event
                    eventController.bookmark = starred[indexPath.row].bookmark
                } else if indexPath.section == (offset + 2) {
                    eventController.event = liveNow[indexPath.row].event
                    eventController.bookmark = liveNow[indexPath.row].bookmark
                }
                navigationController?.pushViewController(eventController, animated: true)
            }
        } else if indexPath.section == (offset + 0) {
            if let storyboard = storyboard, let controller = storyboard.instantiateViewController(withIdentifier: "HTNewsTableViewController") as? HTNewsTableViewController {
                navigationController?.pushViewController(controller, animated: true)
            }
        } else if indexPath.section == (offset + 1) || indexPath.section == (offset + 2) {
            if let storyboard = storyboard, let controller = storyboard.instantiateViewController(withIdentifier: "HTScheduleTableViewController") as? HTScheduleTableViewController {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
