//
//  HTScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/15/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTScheduleTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    var events:NSArray = []
    var selectedEvent:Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!

        //NSLog("Getting full schedule")
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.returnsObjectsAsFaults = false
        var err:NSError? = nil
        self.events = context.executeFetchRequest(fr, error: &err)!
        
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset.top = 22
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // NSLog("have \(self.events.count) events to display")
        return self.events.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! UITableViewCell

        var event : Event = self.events.objectAtIndex(indexPath.row) as! Event
        cell.textLabel!.text = event.title
        cell.detailTextLabel!.text = "\(event.location) : \(event.name)"
        
        //NSLog("built cell for \(event.title)")

        return cell
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "eventDetailSegue") {
            var dv : HTEventDetailViewController = segue.destinationViewController as! HTEventDetailViewController
            let indexPath : NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            dv.event = self.events.objectAtIndex(indexPath.row) as! Event
        }
    }
    

}
