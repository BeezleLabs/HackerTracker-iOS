//
//  HTEventsTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/27/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

struct eventType {
    var name:String
    var img:String
    var dbName:String
    var count:Int
   
    init(n:String,i:String,d:String,c:Int) {
        self.name = n
        self.img = i
        self.dbName = d
        self.count = c
    }
}

class HTEventsTableViewController: UITableViewController {
    
    var eventTypes: [eventType] = [
        eventType(n: "CONTESTS", i: "contest", d: "Contest", c: 0),
        eventType(n: "EVENTS", i: "event", d: "Event", c: 0),
        eventType(n: "PARTIES", i: "party", d: "Party", c: 0),
        eventType(n: "KIDS", i: "kids", d: "Kids", c: 0),
        eventType(n: "SKYTALKS", i: "cloud", d: "Skytalks", c: 0),
        eventType(n: "TALKS", i: "speaker", d: "Speaker", c: 0),
        eventType(n: "VILLAGES", i: "village", d: "Villages", c: 0),
        eventType(n: "WORKSHOPS", i:"workshop", d:"Workshop", c: 0)

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        automaticallyAdjustsScrollViewInsets = true
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        
        for e:eventType in eventTypes {
            fr.predicate = NSPredicate(format: "type = %@", argumentArray: [e.dbName])
            _ = try! context.executeFetchRequest(fr)
            
            var mutableE = e
            mutableE.count = context.countForFetchRequest(fr, error: nil)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventTypes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) 

        var event : eventType
        event = self.eventTypes[indexPath.row]
        
        cell.textLabel!.text = event.name
        cell.imageView?.image = UIImage(named: event.img)

        return cell
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "eventSegue") {
            let sv : HTScheduleTableViewController = segue.destinationViewController as! HTScheduleTableViewController
            let indexPath: NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            let ev = self.eventTypes[indexPath.row]
            sv.eType = ev
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

}
