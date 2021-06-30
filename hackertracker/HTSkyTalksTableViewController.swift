//
//  HTSkyTalksTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/25/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTSkyTalksTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    var events: NSArray = []
    var selectedEvent: Event?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!

        let fr: NSFetchRequest = NSFetchRequest(entityName: "Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        fr.predicate = NSPredicate(format: "type = 'Skytalks'", argumentArray: nil)
        var err: NSError?
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
        return self.events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("skytalkCell", forIndexPath: indexPath) as! UITableViewCell

        var event: Event = self.events.objectAtIndex(indexPath.row) as! Event
        let df = NSDateFormatter()
        df.dateFormat = "EE HH:mm"
        let beginDate = df.stringFromDate(event.begin)
        df.dateFormat = "HH:mm"
        let endDate = df.stringFromDate(event.end)

        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "\(beginDate)-\(endDate) (\(event.location))"

        return cell
    }

    /*override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var myEvent : Event = self.events.objectAtIndex(indexPath.row) as! Event
        selectedEvent = myEvent
        self.performSegueWithIdentifier("skytalkDetailSegue", sender: self)
    }*/

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "skytalkDetailSegue" {
            var dv: HTEventDetailViewController = segue.destinationViewController as! HTEventDetailViewController
            dv.event = selectedEvent
        }
    }

}
