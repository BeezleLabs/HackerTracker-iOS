//
//  HTScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/15/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
import SpriteKit

class BaseScheduleTableViewController: UITableViewController, EventDetailDelegate {
    
    typealias EventSection = (date: String, events: [UserEventModel])

    var eventSections : [EventSection] = []
    var allEventSections : [EventSection] = []
    var data = NSMutableData()
    var emptyStateView : UIView?
    var lastContentOffset: CGPoint?
    var updated : [String] = []
    var later : [String] = []
    
    var eventTokens : [UpdateToken?] = []


    var pullDownAnimation: PongScene?
    var nowPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "EventCell", bundle: Bundle(for: EventCell.self)), forCellReuseIdentifier: "EventCell")
        self.title = AnonymousSession.shared.currentConference.code
        self.reloadEvents()
        tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.middle, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isViewLoaded && !animated  {
            reloadEvents()

            if let lastContentOffset = lastContentOffset {
                tableView.contentOffset = lastContentOffset
                tableView.layoutIfNeeded()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()

        if pullDownAnimation == nil {
            refreshControl = UIRefreshControl()
            let attr: Dictionary = [ NSAttributedString.Key.foregroundColor : UIColor.white ]
            refreshControl?.attributedTitle = NSAttributedString(string: "Sync", attributes: attr)
            refreshControl?.tintColor = .clear
            refreshControl?.addTarget(self, action: #selector(self.sync(sender:)), for: UIControl.Event.valueChanged)

            let view = SKView(frame: refreshControl!.frame)
            if let scene = SKScene(fileNamed: "scene") as? PongScene {
                pullDownAnimation = scene
                scene.backgroundColor = .clear
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
                view.ignoresSiblingOrder = true
                view.backgroundColor = .clear

                refreshControl?.addSubview(view)
            }

            tableView.addSubview(refreshControl!)
        }

    }

    func reloadEvents() {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        var event: UserEventModel?

        if let selectedIndexPath = selectedIndexPath {
            event = eventSections[selectedIndexPath.section].events[selectedIndexPath.row]
        }
        
        NSLog("Anonymous session has \(AnonymousSession.shared.events.count) events in it")
        
        if eventSections.count > 0 {
            eventSections.removeAll()
        }
        if allEventSections.count > 0 {
            allEventSections.removeAll()
        }
        
        let dfu = DateFormatterUtility.shared
        let conference = AnonymousSession.shared.currentConference!
        if let start = dfu.yearMonthDayFormatter.date(from: conference.startDate), let end = dfu.yearMonthDayFormatter.date(from: conference.endDate) {
            var k = 0
            for day in dfu.getConferenceDates(start: start, end: end) {
                if eventTokens.indices.contains(k) {
                    //
                } else {
                    let dayToken = FSConferenceDataController.shared.requestEvents(forConference: conference, inDate: dfu.yearMonthDayFormatter.date(from: day)!) { (result) in
                        switch result {
                        case .success(let eventList):
                            //events.append(contentsOf: eventList)
                            NSLog("Got \(eventList.count) events for \(conference.code):\(conference.id)")
                            if eventList.count > 0 {
                                var newDay = true
                                var i = 0
                                for es in self.eventSections {
                                    if es.date == day {
                                        self.eventSections.remove(at: i)
                                        self.eventSections.insert((date: day, events: eventList), at: i)
                                        newDay = false
                                    }
                                    i = i + 1
                                }
                                
                                if newDay {
                                    self.eventSections.append((date: day, events: eventList))
                                }
                                
                                newDay = true
                                i = 0
                                for aes in self.allEventSections {
                                    if aes.date == day {
                                        self.allEventSections.remove(at: i)
                                        self.allEventSections.insert((date: day, events: eventList), at: i)
                                        newDay = false
                                    }
                                    i = i + 1
                                }
                                if newDay {
                                    self.allEventSections.append((date: day, events: eventList))
                                }
                                //self.eventSections.append((date: day, events: events))
                                //self.allEventSections.append((date: day, events: events))
                            }
                            /*for event in events {
                                FSConferenceDataController.shared.setFavorite(forConference: AnonymousSession.shared.currentConference, eventModel: event.event, isFavorite: true, session: AnonymousSession.shared, updateHandler: { (error) in
                             
                                })
                            }*/
                            self.tableView.reloadData()
                        case .failure(let _):
                            NSLog("")
                        }
                    }
                    eventTokens.append(dayToken)
                }
                k = k + 1
            }
        }
        
        let emptyStateView = self.emptyStateView ?? emptyState()

        self.emptyStateView = emptyStateView
        emptyStateView.isHidden = eventSections.count != 0

        tableView.reloadData()

        if let selectedIndexPath = selectedIndexPath,
            let event = event,
            selectedIndexPath.section < eventSections.count,
            selectedIndexPath.row < eventSections[selectedIndexPath.section].events.count {

            let newEvent = eventSections[selectedIndexPath.section].events[selectedIndexPath.row]
            if newEvent.event.id == event.event.id {
                tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    public func emptyState() -> UIView {
        if let emptyState = Bundle.main.loadNibNamed("ScheduleEmptyStateView", owner: self, options: nil)?.first as? ScheduleEmptyStateView {
            return emptyState
        }
        return UIView()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if eventSections.count == 0 {
            if tableView.tableHeaderView  != emptyStateView {
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
        if let tableHeader = tableView.tableHeaderView, let emptyState = emptyStateView,  tableView.tableHeaderView == emptyStateView {
            if floor(emptyState.frame.size.height) != floor(tableHeader.frame.size.height) {
                emptyStateView?.frame.size.height = floor(tableView.frame.size.height)
                tableView.tableHeaderView = emptyStateView
                tableView.layoutIfNeeded()
            }
        }

        if let refreshControl = refreshControl,
            tableView.subviews.contains(refreshControl) {
            tableView.sendSubviewToBack(refreshControl)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard eventSections.count > section else {
            return 0
        }
        
        return self.eventSections[section].events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        let e = self.eventSections[indexPath.section].events[indexPath.row]

        cell.bind(userEvent: e)

        return cell
    }

    func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        return fr
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (eventSections.count == 0) {
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
        if (eventSections.count == 0) {
            return tableView.frame.size.height
        } else {
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let storyboard = self.storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
            eventController.event = self.eventSections[indexPath.section].events[indexPath.row].event
            eventController.bookmark = self.eventSections[indexPath.section].events[indexPath.row].bookmark
            eventController.delegate = self
            self.navigationController?.pushViewController(eventController, animated: true)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        lastContentOffset = tableView.contentOffset
        if (segue.identifier == "eventDetailSegue") {

            let dv : HTEventDetailViewController

            if let destinationNav = segue.destination as? UINavigationController, let _dv = destinationNav.viewControllers.first as? HTEventDetailViewController {
                dv = _dv
            } else {
                dv = segue.destination as! HTEventDetailViewController
            }

            var indexPath: IndexPath
            if let ec = sender as? EventCell {
                indexPath = tableView.indexPath(for: ec)! as IndexPath
            } else {
                indexPath = sender as! IndexPath
            }

            dv.event = self.eventSections[indexPath.section].events[indexPath.row].event
            dv.bookmark = self.eventSections[indexPath.section].events[indexPath.row].bookmark
            dv.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    @objc func sync(sender: AnyObject) {
        pullDownAnimation?.play()

        Timer.scheduledTimer(timeInterval: TimeInterval(3.0), target: self, selector: #selector(timerComplete), userInfo: nil, repeats: false)
        
        
    }
    
    @objc func timerComplete() {
        pullDownAnimation?.reset()
    }

}

class HTScheduleTableViewController: BaseScheduleTableViewController, FilterViewControllerDelegate {
    
    var eType : EventType?
    var alltypes: [HTEventType] = []
    var filteredtypes: [HTEventType] = []
    var filterView: HTFilterViewController?
    
    var typesToken: UpdateToken?
    
    var showSectionIndexTitles = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getEventTypes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //reloadEvents()
        
        tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.middle, animated: false)
        tableView.backgroundColor = UIColor.backgroundGray
    }
    
    func getEventTypes() {
        typesToken = FSConferenceDataController.shared.requestEventTypes(forConference: AnonymousSession.shared.currentConference!) { (result) in
            switch result {
            case .success(let typeList):
                self.alltypes.append(contentsOf: typeList)
            case .failure(let _):
                NSLog("")
            }
        }
    }

    public override func emptyState() -> UIView {
        if let emptyState = Bundle.main.loadNibNamed("ScheduleEmptyStateView", owner: self, options: nil)?.first as? ScheduleEmptyStateView {
            emptyState.bind(description: "No events for this date yet. Pull down to refresh or check back later.", image: #imageLiteral(resourceName: "skull-active"))
            return emptyState
        }
        return UIView()
    }
    
    public override func sectionIndexTitles(for tableView: UITableView) -> [String]? {

        var ret : [String] = []
        let dfu = DateFormatterUtility.shared
        for es in eventSections {
                if let date = dfu.yearMonthDayFormatter.date(from: es.date) {
                    let out = dfu.shortDayOfMonthFormatter.string(from: date)
                    if out.contains("Mon") {
                            ret.append("M")
                    } else if out.contains("Tue") {
                            ret.append("T")
                    } else if out.contains("Wed") {
                            ret.append("W")
                    } else if out.contains("Thu") {
                            ret.append("H")
                    } else if out.contains("Fri") {
                            ret.append("F")
                    } else if out.contains("Sat") {
                            ret.append("S")
                    } else if out.contains("Sun") {
                            ret.append("S")
                    }
                }
        }
        return ret
    }
    
    func reloadFilteredEvents() {
        var newEventSections : [EventSection] = []
        for es in allEventSections {
            var newEvents : [UserEventModel] = []
            for e in es.events {
                if filteredtypes.contains(e.event.type) {
                    newEvents.append(e)
                }
            }
            if newEvents.count > 0 {
                newEventSections.append((date: es.date, events: newEvents))
            }
        }
        self.eventSections = newEventSections
        self.tableView.reloadData()
    }

    
    func filterList(filteredEventTypes: [HTEventType]) {
        self.filteredtypes = filteredEventTypes
        self.reloadFilteredEvents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "filterSegue" {
            let fvc = storyboard?.instantiateViewController(withIdentifier: "filterViewController") as! HTFilterViewController
            fvc.delegate = self
            fvc.all = alltypes
            fvc.filtered = filteredtypes
            present(fvc, animated:false, completion:nil)
            
        } else if (segue.identifier == "eventDetailSegue") {
            
            let dv : HTEventDetailViewController
            
            if let destinationNav = segue.destination as? UINavigationController, let _dv = destinationNav.viewControllers.first as? HTEventDetailViewController {
                dv = _dv
            } else {
                dv = segue.destination as! HTEventDetailViewController
            }
            
            var indexPath: IndexPath
            if let ec = sender as? EventCell {
                indexPath = tableView.indexPath(for: ec)! as IndexPath
            } else {
                indexPath = sender as! IndexPath
            }
            
            dv.event = self.eventSections[indexPath.section].events[indexPath.row].event
            dv.bookmark = self.eventSections[indexPath.section].events[indexPath.row].bookmark
            dv.delegate = self
        }
    }
    
}



