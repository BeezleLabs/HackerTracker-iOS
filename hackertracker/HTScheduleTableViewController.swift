//
//  HTScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/15/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import CoreData
import SpriteKit
import UIKit

class BaseScheduleTableViewController: UITableViewController {
    typealias EventSection = (date: String, events: [UserEventModel])

    var eventSections: [EventSection] = []
    var allEventSections: [EventSection] = []
    var data = NSMutableData()
    var emptyStateView: UIView?
    var lastContentOffset: CGPoint?
    var updated: [String] = []
    var later: [String] = []
    var allTags: [HTTag] = []
    var filteredTags: [HTTag] = []
    var filteredTagIds: [Int] = []
    var firstLoad = true
    var touchNav: UITapGestureRecognizer! // swiftlint:disable:this implicitly_unwrapped_optional

    var eventTokens: [UpdateToken?] = []

    var pullDownAnimation: PongScene?
    var nowPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "EventCell", bundle: Bundle(for: EventCell.self)), forCellReuseIdentifier: "EventCell")
        // Create title button
        let titleViewButton = UIButton(type: .system)
        titleViewButton.setTitleColor(UIColor.white, for: .normal)
        titleViewButton.setTitle(AnonymousSession.shared.currentConference.name, for: .normal)
        titleViewButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        titleViewButton.imageView?.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
        titleViewButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        titleViewButton.semanticContentAttribute = .forceRightToLeft

        navigationItem.titleView = titleViewButton

        tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.middle, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isViewLoaded && !animated {
            if let lastContentOffset = lastContentOffset {
                tableView.contentOffset = lastContentOffset
                tableView.layoutIfNeeded()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func emptyState() -> UIView {
        if let emptyState = Bundle.main.loadNibNamed("ScheduleEmptyStateView", owner: self, options: nil)?.first as? ScheduleEmptyStateView {
            return emptyState
        }
        return UIView()
    }

    @objc func scrollToCurrentDate(_ sender: Any) {
        let curDate = Date()
        // Debug below to jump to next events for LOCOMOCOSEC schedule
        // let curDate = DateFormatterUtility.shared.iso8601Formatter.date(from: "2022-06-28T11:43:01.000-0700")!
        if !self.eventSections.isEmpty {
            fullloop: for sectionIndex in 0..<self.eventSections.count {
                if !self.eventSections[sectionIndex].events.isEmpty {
                    for eventIndex in 0..<self.eventSections[sectionIndex].events.count {
                        let userEvent = self.eventSections[sectionIndex].events[eventIndex]
                        if userEvent.event.begin > curDate {
                            let indexPath = IndexPath(row: eventIndex, section: sectionIndex)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            break fullloop
                        }
                    }
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    break fullloop
                } else {
                    break fullloop
                }
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if eventSections.isEmpty {
            if tableView.tableHeaderView != emptyStateView {
                emptyStateView?.frame.size.height = tableView.frame.size.height
                tableView.tableHeaderView = emptyStateView
            }
        } else {
            tableView.tableHeaderView = nil
        }
        return eventSections.count
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let tableHeader = tableView.tableHeaderView, let emptyState = emptyStateView, tableView.tableHeaderView == emptyStateView {
            if floor(emptyState.frame.size.height) != floor(tableHeader.frame.size.height) {
                emptyStateView?.frame.size.height = floor(tableView.frame.size.height)
                tableView.tableHeaderView = emptyStateView
                tableView.layoutIfNeeded()
            }
        }

        /* if let refreshControl = refreshControl,
           tableView.subviews.contains(refreshControl) {
            tableView.sendSubviewToBack(refreshControl)
        } */
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard eventSections.count > section else {
            return 0
        }

        if eventSections[section].events.isEmpty {
            return 0
        }

        return self.eventSections[section].events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.bind(userEvent: eventSections[indexPath.section].events[indexPath.row])
        return cell
    }

    func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if eventSections.isEmpty || eventSections[section].events.isEmpty {
            return emptyStateView
        }

        let dayText = eventSections[section].date
        let dfu = DateFormatterUtility.shared
        let date = dfu.yearMonthDayFormatter.date(from: dayText)

        let dateHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EventHeader") as? EventDateHeaderView ?? EventDateHeaderView(reuseIdentifier: "EventHeader")

        dateHeader.bindToDate(date: date)

        return dateHeader
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if eventSections.isEmpty || eventSections[section].events.isEmpty {
            return tableView.frame.size.height
        } else {
            return 40
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// swiftlint:disable:this type_body_length
class HTScheduleTableViewController: BaseScheduleTableViewController, FilterViewControllerDelegate, EventCellDelegate, HTConferenceTableViewControllerDelegate, EventDetailDelegate {
    var filterView: HTFilterViewController?

    var tagsToken: UpdateToken?

    var showSectionIndexTitles = false
    var selectedIndexPath: IndexPath?

    // Floating button stuff
    private var filterButton = UIButton(type: .custom)
    private var nowButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        if tagsToken == nil {
            let tvb = navigationItem.titleView as! UIButton
            tvb.addTarget(self, action: #selector(displayConferencePicker(sender:)), for: .touchUpInside)

            getTagTypes()
            if eventTokens.isEmpty {
                self.setupTokens()
            }
            self.filterButton.addTarget(self, action: #selector(filterClick(sender:)), for: UIControl.Event.touchUpInside)
            self.navigationController?.view.addSubview(filterButton)

            self.nowButton.addTarget(self, action: #selector(scrollToCurrentDate(_:)), for: UIControl.Event.touchUpInside)
            self.navigationController?.view.addSubview(nowButton)
        }
        reloadFilteredEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.filterButton.isHidden = false
        self.filterButton.isUserInteractionEnabled = true

        self.nowButton.isHidden = false
        self.nowButton.isUserInteractionEnabled = true

        tableView.backgroundColor = UIColor.backgroundGray
    }

    @objc func displayConferencePicker(sender: AnyObject) {
        let cvc = storyboard?.instantiateViewController(withIdentifier: "HTConferenceTableViewController") as! HTConferenceTableViewController
        cvc.delegate = self
        present(cvc, animated: false)
    }

    func didSelect(conference: ConferenceModel) {
        if let menuvc = self.navigationController?.parent as? HTHamburgerMenuViewController {
            menuvc.didSelectID(tabID: "Schedule")
            menuvc.backgroundTapped()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.filterButton.isHidden = true
            self.filterButton.isUserInteractionEnabled = false
            self.nowButton.isHidden = true
            self.nowButton.isUserInteractionEnabled = false
        }
        super.viewWillDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        filterButton.layer.cornerRadius = filterButton.layer.frame.size.width / 2
        filterButton.backgroundColor = UIColor.black
        filterButton.clipsToBounds = true
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                                        filterButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
                                        filterButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
                                        filterButton.widthAnchor.constraint(equalToConstant: 50),
                                        filterButton.heightAnchor.constraint(equalToConstant: 50), ])

        nowButton.layer.cornerRadius = nowButton.layer.frame.size.width / 2
        nowButton.backgroundColor = UIColor.black
        nowButton.clipsToBounds = true
        nowButton.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)
        nowButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nowButton.trailingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 60),
            nowButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            nowButton.widthAnchor.constraint(equalToConstant: 50),
            nowButton.heightAnchor.constraint(equalToConstant: 50), ])
    }

    @objc func filterClick(sender: AnyObject) {
        let fvc = storyboard?.instantiateViewController(withIdentifier: "filterViewController") as! HTFilterViewController
        fvc.delegate = self
        fvc.all = allTags
        fvc.filtered = filteredTags
        present(fvc, animated: false)
    }

    func getTagTypes() {
        tagsToken = FSConferenceDataController.shared.requestTags(forConference: AnonymousSession.shared.currentConference) { result in
            switch result {
            case .success(let tagTypeList):
                self.allTags.removeAll()
                for tagType in tagTypeList where tagType.label.lowercased().contains("event category") {
                    self.allTags.reserveCapacity(tagType.tags.count)
                    for tag in tagType.tags {
                        var insertIndex = 0
                        for curTag in self.allTags {
                            if curTag.sortOrder > tag.sortOrder {
                                break
                            }
                            insertIndex += 1
                        }
                        self.allTags.insert(tag, at: insertIndex)
                        // self.allTags.append(tag)
                    }
                }
                self.filteredTags = self.allTags
            case .failure:
                // TODO: Properly log failure
                break
            }
        }
    }

    func updatedEvents() {
        self.reloadFilteredEvents()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.bind(userEvent: eventSections[indexPath.section].events[indexPath.row])
        cell.eventCellDelegate = self
        return cell
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

    override func emptyState() -> UIView {
        if let emptyState = Bundle.main.loadNibNamed("ScheduleEmptyStateView", owner: self, options: nil)?.first as? ScheduleEmptyStateView {
            emptyState.bind(description: "No events for this date yet. Pull down to refresh or check back later.", image: #imageLiteral(resourceName: "skull-active"))
            return emptyState
        }
        return UIView()
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles: [String] = []
        let dfu = DateFormatterUtility.shared
        for eventSection in eventSections {
            if !eventSection.events.isEmpty, let date = dfu.yearMonthDayFormatter.date(from: eventSection.date) {
                let out = dfu.shortDayOfMonthFormatter.string(from: date)
                if out.contains("Mon") {
                    titles.append("M")
                } else if out.contains("Tue") {
                    titles.append("T")
                } else if out.contains("Wed") {
                    titles.append("W")
                } else if out.contains("Thu") {
                    titles.append("H")
                } else if out.contains("Fri") {
                    titles.append("F")
                } else if out.contains("Sat") {
                    titles.append("S")
                } else if out.contains("Sun") {
                    titles.append("S")
                }
            }
        }
        return titles
    }

    func reloadFilteredEvents() {
        filteredTagIds = filteredTags.compactMap { tag in
            tag.id
        }
        var newEventSections: [EventSection] = []
        for eventSection in allEventSections {
            var newEvents: [UserEventModel] = []
            for userEvent in eventSection.events {
                for tagId in userEvent.event.tagIds where filteredTagIds.contains(tagId) {
                    newEvents.append(userEvent)
                    break
                }
            }
            if !newEvents.isEmpty {
                newEventSections.append((date: eventSection.date, events: newEvents))
            }
        }
        self.eventSections = newEventSections
        self.tableView.reloadData()
    }

    func reloadEvents() {
        if let indexPath = self.selectedIndexPath {
            self.eventSections[indexPath.section].events[indexPath.row].bookmark.value.toggle()
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    func filterList(filteredTags: [HTTag]) {
        self.filteredTags = filteredTags
        self.reloadFilteredEvents()
    }

    func setupTokens() { // swiftlint:disable:this cyclomatic_complexity function_body_length
        let dfu = DateFormatterUtility.shared
        let conference = AnonymousSession.shared.currentConference
        if let start = dfu.yearMonthDayFormatter.date(from: conference.startDate), let end = dfu.yearMonthDayFormatter.date(from: conference.endDate) {
            var k = 0 // swiftlint:disable:this identifier_name

            for day in dfu.getConferenceDates(start: start, end: end) {
                if eventTokens.indices.contains(k) {
                    // token already exists, don't need to do anything here
                } else {
                    let dayToken = FSConferenceDataController.shared.requestEvents(forConference: conference, inDate: dfu.yearMonthDayFormatter.date(from: day) ?? Date()) { result in
                        switch result {
                        case .success(let eventList):
                            if !eventList.isEmpty {
                                // Event List already exists
                                var newDay = true
                                var idx = 0
                                for eventSection in self.eventSections {
                                    // Go through event sections that exist
                                    if eventSection.date == day {
                                        // Section exists and is the right day
                                        // Start by removing the current eventSection
                                        self.eventSections.remove(at: idx)

                                        var newEvents: [UserEventModel] = []
                                        if self.filteredTagIds.isEmpty {
                                            newEvents = eventList
                                        } else {
                                            for userEvent in eventList {
                                                for tagId in userEvent.event.tagIds {
                                                    if self.filteredTagIds.contains(tagId) {
                                                        newEvents.append(userEvent)
                                                    }
                                                }
                                            }
                                        }

                                        if !newEvents.isEmpty {
                                            // Only add the section if there are events in it
                                            self.eventSections.insert((date: day, events: newEvents), at: idx)
                                        }

                                        newDay = false
                                    }
                                    idx += 1
                                }
                                if newDay {
                                    var newEvents: [UserEventModel] = []
                                    if self.filteredTagIds.isEmpty {
                                        newEvents = eventList
                                    } else {
                                        for userEvent in eventList {
                                            for tagId in userEvent.event.tagIds {
                                                if self.filteredTagIds.contains(tagId) {
                                                    newEvents.append(userEvent)
                                                }
                                            }
                                        }
                                    }
                                    if !newEvents.isEmpty {
                                        // Only add the section if there are events in it, make sure the sections are ordered
                                        var insertIndex = 0
                                        idxloop: for section in self.eventSections {
                                            if let fullDay = dfu.yearMonthDayFormatter.date(from: day),
                                               let secDay = dfu.yearMonthDayFormatter.date(from: section.date),
                                            fullDay < secDay {
                                                break idxloop
                                            }
                                            insertIndex += 1
                                        }
                                        self.eventSections.insert((date: day, events: newEvents), at: insertIndex)
                                    }
                                }

                                // Handle the list of all events
                                newDay = true
                                idx = 0
                                for aes in self.allEventSections {
                                    if aes.date == day {
                                        self.allEventSections.remove(at: idx)
                                        self.allEventSections.insert((date: day, events: eventList), at: idx)
                                        newDay = false
                                    }
                                    idx += 1
                                }
                                if newDay {
                                    self.allEventSections.append((date: day, events: eventList))
                                }
                            }

                            self.tableView.reloadData()
                        case .failure:
                            break
                        }
                    }
                    eventTokens.append(dayToken)
                }
                k += 1
            }
        }
    }
}

// swiftlint:disable:this file_length
