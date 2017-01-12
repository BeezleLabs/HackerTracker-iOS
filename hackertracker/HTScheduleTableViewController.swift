//
//  HTScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/15/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTScheduleTableViewController: UITableViewController {
    
    var eventSections : [[Event]] = []
    
    var eType : eventType!
        
    var days = ["2016-08-04", "2016-08-05", "2016-08-06", "2016-08-07"];
    
    let highlightColor = UIColor(red: 120/255.0, green: 114/255.0, blue: 255/255.0, alpha: 1)
    
    override func viewWillAppear(_ animated: Bool) {
        
        reloadEvents()
        
        self.title = eType.name
    }
    
    fileprivate func reloadEvents() {
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
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) 

        let event : Event = self.eventSections[indexPath.section][indexPath.row]
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "PDT")
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "EE HH:mm"
        let beginDate = df.string(from: event.begin as Date)
        df.dateFormat = "HH:mm"
        let endDate = df.string(from: event.end as Date)
        
        cell.textLabel!.text = event.title
        
        if (event.starred) {
            cell.textLabel!.text = "** \(event.title) **"
            cell.textLabel!.textColor = self.highlightColor
        } else {
            cell.textLabel!.text = event.title
            cell.textLabel!.textColor = UIColor.white
        }
        
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location))"
        
        return cell
    }
    
    @IBAction func goBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func RetrieveEventsForDay(_ dateString: String) -> [AnyObject] {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "PDT")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        df.locale = Locale(identifier: "en_US_POSIX")

        let startofDay: Date = df.date(from: "\(dateString) 00:00:00 PDT")!
        let endofDay: Date = df.date(from: "\(dateString) 23:59:59 PDT")!

        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "type = %@ AND begin >= %@ AND end <= %@", argumentArray: [eType.dbName, startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false

        return try! context.fetch(fr)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return days[section]
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "eventDetailSegue") {
            let dv : HTEventDetailViewController = segue.destination as! HTEventDetailViewController
            let indexPath : IndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            dv.event = self.eventSections[indexPath.section][indexPath.row]
        }
    }
    

}
