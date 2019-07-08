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
    
    typealias EventSection = (date: String, events: [HTEventModel])

    var eventSections : [EventSection] = []
    var data = NSMutableData()
    var emptyStateView : UIView?
    var lastContentOffset: CGPoint?
    var updated : [String] = []
    var later : [String] = []
    
    var myCon: ConferenceModel?
    var conferencesToken : UpdateToken<ConferenceModel>?
    var eventTokens : [UpdateToken<HTEventModel>] = []


    var pullDownAnimation: PongScene?
    var nowPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "EventCell", bundle: Bundle(for: EventCell.self)), forCellReuseIdentifier: "EventCell")
        if let conCode = UserDefaults.standard.string(forKey: "conference"){
            self.title = conCode
            conferencesToken = FSConferenceDataController.shared.requestConferenceByCode(forCode: conCode) { (result) in
                switch result {
                case .success(let con):
                    self.myCon = con
                    self.title = con.name
                    self.reloadEvents()
                case .failure(let _):
                    NSLog("")
                }
            }
        } else {
            NSLog("No conference set, send to conferences")
            guard let menuvc = self.navigationController?.parent as? HTHamburgerMenuViewController else {
                NSLog("Couldn't find parent view controller")
                return
            }
            menuvc.setCurrentViewController(tabID: "Conferences")
        }
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
        var event: HTEventModel?

        if let selectedIndexPath = selectedIndexPath {
            event = eventSections[selectedIndexPath.section].events[selectedIndexPath.row]
        }
        
        if eventSections.count > 0 {
            eventSections.removeAll()
        }
        
        let dfu = DateFormatterUtility.shared
        if let c = myCon, let start = dfu.yearMonthDayFormatter.date(from: c.startDate), let end = dfu.yearMonthDayFormatter.date(from: c.endDate) {
            for day in dfu.getConferenceDates(start: start, end: end) {
                var events : [HTEventModel] = []
                let dayToken = FSConferenceDataController.shared.requestEvents(forConference: c, inDate: dfu.yearMonthDayFormatter.date(from: day)!) { (result) in
                    switch result {
                    case .success(let eventList):
                        events.append(contentsOf: eventList)
                        //NSLog("Got \(eventList.count) events for \(c.code):\(c.id)")
                        if events.count > 0 {
                            self.eventSections.append((date: day, events: events))
                        }
                        self.tableView.reloadData()
                    case .failure(let _):
                        NSLog("")
                    }
                }
                eventTokens.append(dayToken)
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
            if newEvent.id == event.id {
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
        let e : HTEventModel = self.eventSections[indexPath.section].events[indexPath.row]

        cell.bind(event: e)

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
        let delegate = UIApplication.shared.delegate as! AppDelegate
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
            eventController.event = self.eventSections[indexPath.section].events[indexPath.row]
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

            dv.event = self.eventSections[indexPath.section].events[indexPath.row]
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
    var alltypes: [EventType] = []
    var filteredtypes: [EventType] = []
    var filterView: HTFilterViewController?
    
    var showSectionIndexTitles = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let drm = DataRequestManager(managedContext: getContext())
        if let con = drm.getSelectedConference() {
            if let n = con.name {
                self.title = n
            }
            alltypes = drm.getEventTypes(con: con)
            filteredtypes = alltypes
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadEvents()
        
        tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.middle, animated: false)
        tableView.backgroundColor = UIColor.backgroundGray
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
    
    override func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {
        let dfu = DateFormatterUtility.shared
        let startofDay: Date =  dfu.yearMonthDayNoTimeZoneTimeFormatter.date(from: "\(dateString) 00:00:00")!
        let endofDay: Date =  dfu.yearMonthDayNoTimeZoneTimeFormatter.date(from: "\(dateString) 23:59:59")!
        
        let con = DataRequestManager(managedContext: getContext()).getSelectedConference()!
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        let now = Date()
        if now > con.start_date! && now < con.end_date! {
            fr.predicate = NSPredicate(format: "event_type IN %@ AND start_date > %@ AND start_date < %@ AND end_date > %@ and conference = %@", argumentArray: [filteredtypes, startofDay, endofDay, Date(), con])
        } else {
            fr.predicate = NSPredicate(format: "event_type IN %@ AND start_date > %@ AND start_date < %@ and conference = %@", argumentArray: [filteredtypes, startofDay, endofDay, con])
        }
        
        
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false

        return fr
    }

    
    func filterList(filteredEventTypes: [EventType]) {
        self.filteredtypes = filteredEventTypes
        self.reloadEvents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "filterSegue" {
            let fvc = storyboard?.instantiateViewController(withIdentifier: "filterViewController") as! HTFilterViewController
            fvc.delegate = self
            let drm = DataRequestManager(managedContext: getContext())
            if let con = drm.getSelectedConference() {
                fvc.all = drm.getEventTypes(con: con)
            }
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
            
            dv.event = self.eventSections[indexPath.section].events[indexPath.row]
            dv.delegate = self
        }
    }
    
}



