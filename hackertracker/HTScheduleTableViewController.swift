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
    
    typealias EventSection = (date: String, events: [Event])

    var eventSections : [EventSection] = []
    var data = NSMutableData()
    var emptyStateView : UIView?
    var lastContentOffset: CGPoint?
    var updated : [String] = []

    var pullDownAnimation: PongScene?
    var nowPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "EventCell", bundle: Bundle(for: EventCell.self)), forCellReuseIdentifier: "EventCell")
        reloadEvents()
        tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.middle, animated: false)
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
            let attr: Dictionary = [ NSAttributedStringKey.foregroundColor : UIColor.white ]
            refreshControl?.attributedTitle = NSAttributedString(string: "Sync", attributes: attr)
            refreshControl?.tintColor = .clear
            refreshControl?.addTarget(self, action: #selector(self.sync(sender:)), for: UIControlEvents.valueChanged)

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
        var event: Event?

        if let selectedIndexPath = selectedIndexPath {
            event = eventSections[selectedIndexPath.section].events[selectedIndexPath.row]
        }

        eventSections.removeAll()

        let drm = DataRequestManager(managedContext: getContext())
        let myCon = drm.getSelectedConference()
        for day in drm.getConferenceDates(myCon!) {
            let events = retrieveEventsForDay(day)
            if events.count > 0 {
                eventSections.append((date: day, events: events))
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
            if newEvent == event {
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
            tableView.sendSubview(toBack: refreshControl)
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
        let event : Event = self.eventSections[indexPath.section].events[indexPath.row]

        cell.bind(event: event)

        return cell
    }

    func retrieveEventsForDay(_ dateString: String) -> [Event] {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        do {
            if let eventsForDay = try context.fetch(fetchRequestForDay(dateString)) as? [Event] {
                //print("Got \(eventsForDay.count) events for \(dateString)")
                return eventsForDay
            } else {
                assert(false, "Failed to convert fetch response to events array")
                return []
            }
        } catch {
            assert(false, "Failed to fetch events.")
        }
        
        return []
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
        let date = DateFormatterUtility.yearMonthDayFormatter.date(from: dayText)
        
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
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    @objc func sync(sender: AnyObject) {
        pullDownAnimation?.play()
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        let dataManager = DataImportManager(managedContext: context)
        
        let envPlist = Bundle.main.path(forResource: "Connections", ofType: "plist")
        let envs = NSDictionary(contentsOfFile: envPlist!)!
        
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: NSURLSessionPinningDelegate(), delegateQueue: nil)
        let cDispatchGroup = DispatchGroup()
        cDispatchGroup.enter()
        
        // First, get conference to see if there are updates
        let cURL = (envs.value(forKey: "base") as! String) + (envs.value(forKey: "conferences") as! String)
        let conURL = Foundation.URL(string: cURL)
        var request = URLRequest(url: conURL!)
        request.httpMethod = "GET"
        
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            let attr: Dictionary = [ NSAttributedStringKey.foregroundColor : UIColor.white ]
            let n = DateFormatterUtility.monthDayTimeFormatter.string(from: Date())
            
            if let error = error {
                NSLog("DataTask error: " + error.localizedDescription)
                NSLog("request \(request)")
                DispatchQueue.main.async() {
                    self.refreshControl?.attributedTitle = NSAttributedString(string: "Sync Failed at \(n)", attributes: attr)
                    cDispatchGroup.leave()
                }
            } else {
                let resStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let data = resStr?.data(using: String.Encoding.utf8.rawValue) {
                    DispatchQueue.main.async() {
                        
                        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context = delegate.managedObjectContext!
                        
                        context.perform {
                            
                            do {
                                self.updated = try dataManager.importConferences(conData: data)
                            } catch {
                                
                            }
                            DispatchQueue.main.async() {
                                self.refreshControl?.attributedTitle = NSAttributedString(string: "Updated conferences \(n)", attributes: attr)
                                DispatchQueue.main.async() {
                                    for link in self.updated {
                                        let linkURL = Foundation.URL(string: link)
                                        request = URLRequest(url: linkURL!)
                                        request.httpMethod = "GET"
                                        NSLog("Getting data from \(link)")
                                        //cDispatchGroup.enter()
                                        
                                        session.dataTask(with: request, completionHandler: { (data, response, error) in
                                            
                                            let attr: Dictionary = [ NSAttributedStringKey.foregroundColor : UIColor.white ]
                                            let n = DateFormatterUtility.monthDayTimeFormatter.string(from: Date())
                                            
                                            if let error = error {
                                                NSLog("DataTask error: " + error.localizedDescription)
                                                DispatchQueue.main.async() {
                                                    self.refreshControl?.attributedTitle = NSAttributedString(string: "Sync Failed at \(n)", attributes: attr)
                                                    cDispatchGroup.leave()
                                                }
                                            } else {
                                                let resStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                                
                                                if let data = resStr?.data(using: String.Encoding.utf8.rawValue) {
                                                    DispatchQueue.main.async() {
                                                        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                                        let context = delegate.managedObjectContext!
                                                        context.perform {
                                                            let dataManager = DataImportManager(managedContext: context)
                                                            
                                                            do {
                                                                try dataManager.importData(data: data)
                                                            } catch {
                                                                
                                                            }
                                                            DispatchQueue.main.async() {
                                                                self.refreshControl?.attributedTitle = NSAttributedString(string: "Updated at \(n)", attributes: attr)
                                                                self.reloadEvents()
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    DispatchQueue.main.async() {
                                                        cDispatchGroup.leave()
                                                    }
                                                }
                                            }
                                            
                                        }).resume()
                                    }
                                    DispatchQueue.main.async() {
                                        cDispatchGroup.leave()
                                    }
                                }
                            }
                            
                        }
                    }
                } else {
                    DispatchQueue.main.async() {
                        cDispatchGroup.leave()
                    }
                }
            }
            
        }).resume()
        
        
        cDispatchGroup.notify(queue: DispatchQueue.main) {
            self.refreshControl?.endRefreshing()
            self.reloadEvents()
            self.pullDownAnimation?.reset()
        }
        
    }

}

class HTScheduleTableViewController: BaseScheduleTableViewController, FilterViewControllerDelegate {
    
    var eType : EventType?
    var alltypes: [EventType] = []
    var filteredtypes: [EventType] = []
    var filterView: HTFilterViewController?
    
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
        
        tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.middle, animated: false)
        tableView.backgroundColor = UIColor.backgroundGray
    }

    public override func emptyState() -> UIView {
        if let emptyState = Bundle.main.loadNibNamed("ScheduleEmptyStateView", owner: self, options: nil)?.first as? ScheduleEmptyStateView {
            emptyState.bind(description: "No events for this date yet. Pull down to refresh or check back later.", image: #imageLiteral(resourceName: "skull-active"))
            return emptyState
        }
        return UIView()
    }
    
    override func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {
        let startofDay: Date =  DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 00:00:00 PDT")!
        let endofDay: Date =  DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 23:59:59 PDT")!
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "event_type IN %@ AND start_date > %@ AND start_date < %@ AND end_date > %@", argumentArray: [filteredtypes, startofDay, endofDay, Date()])
        //fr.predicate = NSPredicate(format: "event_type IN %@ AND start_date > %@ AND start_date < %@", argumentArray: [filteredtypes, startofDay, endofDay])
        
        
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



