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
    
    override func viewWillAppear(animated: Bool) {
        
        reloadEvents()
        
        self.title = eType.name
    }
    
    private func reloadEvents() {
        for day in days {
            eventSections.append(RetrieveEventsForDay(day).map { (object) -> Event in
                return object as! Event
                })
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return days.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard eventSections.count > section else {
            return 0;
        }
        
        return self.eventSections[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) 

        let event : Event = self.eventSections[indexPath.section][indexPath.row]
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(abbreviation: "PDT")
        df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.dateFormat = "EE HH:mm"
        let beginDate = df.stringFromDate(event.begin)
        df.dateFormat = "HH:mm"
        let endDate = df.stringFromDate(event.end)
        
        cell.textLabel!.text = event.title
        
        if (event.starred) {
            cell.textLabel!.text = "** \(event.title) **"
            cell.textLabel!.textColor = self.highlightColor
        } else {
            cell.textLabel!.text = event.title
            cell.textLabel!.textColor = UIColor.whiteColor()
        }
        
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location))"
        
        return cell
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func RetrieveEventsForDay(dateString: String) -> [AnyObject] {
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone(abbreviation: "PDT")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        df.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        let startofDay: NSDate = df.dateFromString("\(dateString) 00:00:00 PDT")!
        let endofDay: NSDate = df.dateFromString("\(dateString) 23:59:59 PDT")!
                
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.predicate = NSPredicate(format: "type = %@ AND begin >= %@ AND end <= %@", argumentArray: [eType.dbName, startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false

        return try! context.executeFetchRequest(fr)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return days[section]
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "eventDetailSegue") {
            let dv : HTEventDetailViewController = segue.destinationViewController as! HTEventDetailViewController
            let indexPath : NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            dv.event = self.eventSections[indexPath.section][indexPath.row]
        }
    }
    

}
