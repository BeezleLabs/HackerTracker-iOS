//
//  HTEventsTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/27/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTEventsTableViewController: UITableViewController {
    
    class eventType:AnyObject {
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
    
    var eventTypes: NSMutableArray = [
        eventType(n: "CONTESTS", i: "contest", d: "Contest", c: 0),
        eventType(n: "EVENTS", i: "event", d: "Event", c: 0),
        eventType(n: "PARTIES", i: "party", d: "Party", c: 0),
        eventType(n: "KIDS", i: "kids", d: "Kids", c: 0),
        eventType(n: "SKYTALKS", i: "cloud", d: "Skytalks", c: 0),
        eventType(n: "TALKS", i: "speaker", d: "Speaker", c: 0),
        eventType(n: "VILLAGES", i: "village", d: "Villages", c: 0),
        eventType(n: "WORKSHOPS", i:"workshop", d:"Workshop", c: 0)

    ]
        //{ name="Contest";img="Contest.png";dbName="Contest" }] //, "Kids", "Official", "Party", "Skytalks", "Event"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        
        let eventArray = self.eventTypes as AnyObject as! [eventType]
        for e:eventType in eventArray {
            fr.predicate = NSPredicate(format: "type = %@", argumentArray: [e.dbName])
            _ = try! context.executeFetchRequest(fr)
            e.count = context.countForFetchRequest(fr, error: nil)
        }
        
        self.tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return self.eventTypes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) 

        var event : eventType
        event = self.eventTypes.objectAtIndex(indexPath.row) as! eventType
        
        cell.textLabel!.text = event.name
        cell.imageView?.image = UIImage(named: event.img)
        
        //NSLog("built cell for \(event.name)")

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "eventSegue") {
            let sv : HTScheduleTableViewController = segue.destinationViewController as! HTScheduleTableViewController
            let indexPath: NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            let ev = self.eventTypes.objectAtIndex(indexPath.row) as! eventType
            sv.searchTerm = ev.dbName
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

}
