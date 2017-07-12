//
//  HTScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/15/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class BaseScheduleTableViewController: UITableViewController {
    
    var eventSections : [[Event]] = []
    var syncAlert = UIAlertController(title: nil, message: "Syncing...", preferredStyle: .alert)
    var data = NSMutableData()

    // Dates for DC 25
    var days = ["2017-07-27", "2017-07-28", "2017-07-29", "2017-07-30"];
    
    func sync(sender: AnyObject) {
        
        let envPlist = Bundle.main.path(forResource: "Connections", ofType: "plist")
        let envs = NSDictionary(contentsOfFile: envPlist!)!
        
        var tURL = (envs.value(forKey: "base") as! String) + (envs.value(forKey: "schedule") as! String)
        //NSLog("Connecting to \(tURL)")
        let scheduleURL = Foundation.URL(string: tURL)
        
        tURL =  (envs.value(forKey: "base") as! String) + (envs.value(forKey: "speakers") as! String)
        let speakersURL = Foundation.URL(string: tURL)
        
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: NSURLSessionPinningDelegate(), delegateQueue: nil)

        var request = URLRequest(url: speakersURL!)
        request.httpMethod = "GET"
        
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            let attr: Dictionary = [ NSForegroundColorAttributeName : UIColor.white ]
            let n = DateFormatterUtility.monthDayTimeFormatter.string(from: Date())
            
            if let error = error {
                NSLog("DataTask error: " + error.localizedDescription)
                DispatchQueue.main.async() {
                    self.refreshControl?.attributedTitle = NSAttributedString(string: "Sync Failed at \(n)", attributes: attr)
                }
            } else {
                let resStr = NSString(data: data!, encoding: String.Encoding.ascii.rawValue)
                
                let dataFromString = resStr!.data(using: String.Encoding.utf8.rawValue)
                
                if (updateSpeakers(dataFromString!)) {
                    DispatchQueue.main.async() {
                        self.refreshControl?.attributedTitle = NSAttributedString(string: "Updated speakers \(n)", attributes: attr)
                    }
                }
            }
            
        }).resume()
        
        request = URLRequest(url: scheduleURL!)
        request.httpMethod = "GET"
        
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            let attr: Dictionary = [ NSForegroundColorAttributeName : UIColor.white ]
            let n = DateFormatterUtility.monthDayTimeFormatter.string(from: Date())
            
            if let error = error {
                NSLog("DataTask error: " + error.localizedDescription)
                DispatchQueue.main.async() {
                    self.refreshControl?.attributedTitle = NSAttributedString(string: "Sync Failed at \(n)", attributes: attr)
                }
            } else {
                let resStr = NSString(data: data!, encoding: String.Encoding.ascii.rawValue)
            
                let dataFromString = resStr!.data(using: String.Encoding.utf8.rawValue)

                if (updateSchedule(dataFromString!)) {
                    DispatchQueue.main.async() {
                        self.refreshControl?.attributedTitle = NSAttributedString(string: "Updated \(n)", attributes: attr)
                    }
                } else {
                    DispatchQueue.main.async() {
                        self.refreshControl?.attributedTitle = NSAttributedString(string: "Last sync at \(n)", attributes: attr)
                    }
                }
            
            }
            DispatchQueue.main.async() {
                self.refreshControl?.endRefreshing()
            }
        }).resume()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(EventCell.self, forCellReuseIdentifier: "Events")
        
        refreshControl = UIRefreshControl()
        let attr: Dictionary = [ NSForegroundColorAttributeName : UIColor.white ]
        refreshControl?.attributedTitle = NSAttributedString(string: "Sync", attributes: attr)
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(self.sync(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadEvents()
    }
    
    fileprivate func reloadEvents() {
        eventSections.removeAll()

        for day in days {
            eventSections.append(RetrieveEventsForDay(day).map { (object) -> Event in
                return object as! Event
                })
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard eventSections.count > section else {
            return 0;
        }
        
        return self.eventSections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        let event : Event = self.eventSections[indexPath.section][indexPath.row]

        cell.bind(event: event)
        
        return cell
    }

    func RetrieveEventsForDay(_ dateString: String) -> [AnyObject] {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!

        return try! context.fetch(fetchRequestForDay(dateString))
    }

    func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {

        let startofDay: Date = DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 00:00:00 PDT")!
        let endofDay: Date =  DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 23:59:59 PDT")!

        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "start_date >= %@ AND end_date <= %@", argumentArray: [ startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false

        return fr
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return days[section]
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "eventDetailSegue") {
            let dv : HTEventDetailViewController = segue.destination as! HTEventDetailViewController
            var indexPath: IndexPath
            if let ec = sender as? EventCell {
                indexPath = tableView.indexPath(for: ec)! as IndexPath
            } else {
                indexPath = sender as! IndexPath
            }
            dv.event = self.eventSections[indexPath.section][indexPath.row]
        }
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let favorite = UITableViewRowAction(style: .normal, title: "Favorite") { (action, indexpath) in

        }
        favorite.backgroundColor = UIColor(red: 0.0/255.0, green: 100.0/255.0, blue: 0.0/255.0, alpha: 1.0)

        return [favorite]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
}

class HTScheduleTableViewController: BaseScheduleTableViewController {
    var eType : eventType!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = eType.name
    }

    override func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {
        let startofDay: Date =  DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 00:00:00 PDT")!
        let endofDay: Date =  DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 23:59:59 PDT")!

        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "entry_type = %@ AND start_date >= %@ AND end_date <= %@", argumentArray: [eType.dbName, startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false

        return fr
    }
}



