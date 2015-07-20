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

    @IBOutlet weak var allButton: UIBarButtonItem!
    @IBOutlet weak var thursdayButton: UIBarButtonItem!
    var isThu:Bool = false
    @IBOutlet weak var fridayButton: UIBarButtonItem!
    var isFri:Bool = false
    @IBOutlet weak var saturdayButton: UIBarButtonItem!
    var isSat:Bool = false
    @IBOutlet weak var sundayButton: UIBarButtonItem!
    var isSun:Bool = false
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let font = UIFont(name: "Helvetica Neue", size: 12.0) {
            clearButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            allButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            thursdayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            fridayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            saturdayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            sundayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isThu {
            filterDay("2015-08-06",button: thursdayButton)
        } else if self.isFri {
            filterDay("2015-08-07",button: fridayButton)
        } else if self.isSat {
            filterDay("2015-08-08",button: saturdayButton)
        } else if self.isSun {
            filterDay("2015-08-09",button: sundayButton)
        } else {

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset.top = 22
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func filterThursday(sender: AnyObject) {
        var dateString = "2015-08-06"
        isThu = true
        isFri = false
        isSat = false
        isSun = false
        filterDay(dateString,button: thursdayButton)
    }
    @IBAction func filterFriday(sender: AnyObject) {
        var dateString = "2015-08-07"
        isThu = false
        isFri = true
        isSat = false
        isSun = false
        filterDay(dateString,button: fridayButton)
    }
    @IBAction func filterSaturday(sender: AnyObject) {
        var dateString = "2015-08-08"
        isThu = false
        isFri = false
        isSat = true
        isSun = false
        filterDay(dateString,button: saturdayButton)
    }
    @IBAction func filterSunday(sender: AnyObject) {
        var dateString = "2015-08-09"
        isThu = false
        isFri = false
        isSat = false
        isSun = true
        filterDay(dateString,button: sundayButton)
    }
    
    @IBAction func filterAll(sender: AnyObject) {
        
        isThu = false
        isFri = false
        isSat = false
        isSun = false
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.predicate = NSPredicate(format: "starred == YES", argumentArray: nil)
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        var err:NSError? = nil
        self.events = context.executeFetchRequest(fr, error: &err)!
        
        deHighlightAll()
        allButton.tintColor = UIColor.greenColor()
        self.tableView.reloadData()
    }

    
    func deHighlightAll() {
        thursdayButton.tintColor = UIColor.whiteColor()
        fridayButton.tintColor = UIColor.whiteColor()
        saturdayButton.tintColor = UIColor.whiteColor()
        sundayButton.tintColor = UIColor.whiteColor()
        allButton.tintColor = UIColor.whiteColor()
    }
    
    func filterDay(dateString: String,button:UIBarButtonItem) {
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var startofDay: NSDate = df.dateFromString("\(dateString) 00:00:00")!
        var endofDay: NSDate = df.dateFromString("\(dateString) 23:59:59")!
        
        //NSLog("Getting schedule for \(self.searchTerm)")
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.predicate = NSPredicate(format: "starred == YES AND begin >= %@ AND end <= %@", argumentArray: [startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        var err:NSError? = nil
        self.events = context.executeFetchRequest(fr, error: &err)!
        
        deHighlightAll()
        button.tintColor = UIColor.greenColor()
        self.tableView.reloadData()
    }

    @IBAction func clearSchedule(sender: AnyObject) {
        var alert : UIAlertController = UIAlertController(title: "Clear Schedule", message: "Do you want to clear the viewed events from your schedule?", preferredStyle: UIAlertControllerStyle.Alert)
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
