//
//  HTMyScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/18/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTMyScheduleTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var events:NSArray = []
    var selectedEvent : Event?

    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let font = UIFont(name: "Helvetica Neue", size: 12.0) {
            clearButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        fr.predicate = NSPredicate(format: "starred == YES", argumentArray: nil)
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

    @IBAction func clearSchedule(sender: AnyObject) {
        var alert : UIAlertController = UIAlertController(title: "Clear Schedule", message: "Do you want to clear your entire schedule?", preferredStyle: UIAlertControllerStyle.Alert)
        var yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
            var myEv:Event
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            for ev in self.events {
                myEv = ev as! Event
                myEv.starred = false
            }
            var err :NSError?
            context.save(&err)
            if err != nil {
                NSLog("%@",err!)
            }
            self.events = []
            self.tableView.reloadData()
            
        })
        var noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction!) in
            NSLog("No")
            //self.tabBarController.selectedIndex = 0
        })
        
        alert.addAction(yesItem)
        alert.addAction(noItem)
        
        self.presentViewController(alert, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("myEventCell", forIndexPath: indexPath) as! UITableViewCell

        var event : Event = self.events.objectAtIndex(indexPath.row) as! Event
        let df = NSDateFormatter()
        df.dateFormat = "EE HH:mm"
        let beginDate = df.stringFromDate(event.begin)
        df.dateFormat = "HH:mm"
        let endDate = df.stringFromDate(event.end)
        
        cell.textLabel!.text = event.title
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location))"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var myEvent : Event = self.events.objectAtIndex(indexPath.row) as! Event
        selectedEvent = myEvent
        self.performSegueWithIdentifier("myEventDetailSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "myEventDetailSegue") {
            var dv : HTEventDetailViewController = segue.destinationViewController as! HTEventDetailViewController
            dv.event = selectedEvent
        }
    }
    

}
