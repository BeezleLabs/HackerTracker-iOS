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

    // TODO: Update for DC 25
    var days = ["2016-08-04", "2016-08-05", "2016-08-06", "2016-08-07"];

    override func viewDidLoad() {
        tableView.register(EventCell.self, forCellReuseIdentifier: "Events")
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "eventDetailSegue", sender: indexPath)
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
        fr.predicate = NSPredicate(format: "begin >= %@ AND end <= %@", argumentArray: [ startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
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
        fr.predicate = NSPredicate(format: "type = %@ AND begin >= %@ AND end <= %@", argumentArray: [eType.dbName, startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false

        return fr
    }
}



