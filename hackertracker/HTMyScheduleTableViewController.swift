//
//  HTMyScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/18/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTMyScheduleTableViewController: UITableViewController {
    
    var events:NSArray = []
    var selectedEvent : Event?

    @IBOutlet weak var toolBar: UIToolbar!
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
    
    let highlightColor = UIColor(red: 120/255.0, green: 114/255.0, blue: 255/255.0, alpha: 1)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let font = UIFont(name: "Courier New", size: 12.0) {
            clearButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            allButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            thursdayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            fridayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            saturdayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            sundayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        deHighlightAll()
        
        allButton.tintColor = toolBar.tintColor

        self.clearsSelectionOnViewWillAppear = false

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isThu {
            filterDay("2016-08-04",button: thursdayButton)
        } else if self.isFri {
            filterDay("2016-08-05",button: fridayButton)
        } else if self.isSat {
            filterDay("2016-08-06",button: saturdayButton)
        } else if self.isSun {
            filterDay("2016-08-07",button: sundayButton)
        } else {

            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
            fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "starred == YES", argumentArray: nil)
            self.events = try! context.executeFetchRequest(fr)
            
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
        let dateString = "2016-08-04"
        isThu = true
        isFri = false
        isSat = false
        isSun = false
        filterDay(dateString,button: thursdayButton)
    }
    @IBAction func filterFriday(sender: AnyObject) {
        let dateString = "2016-08-05"
        isThu = false
        isFri = true
        isSat = false
        isSun = false
        filterDay(dateString,button: fridayButton)
    }
    @IBAction func filterSaturday(sender: AnyObject) {
        let dateString = "2016-08-06"
        isThu = false
        isFri = false
        isSat = true
        isSun = false
        filterDay(dateString,button: saturdayButton)
    }
    @IBAction func filterSunday(sender: AnyObject) {
        let dateString = "2016-08-07"
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
        self.events = try! context.executeFetchRequest(fr)
        
        deHighlightAll()
        allButton.tintColor = toolBar.tintColor
        self.tableView.reloadData()
    }

    
    func deHighlightAll() {
        allButton.tintColor = UIColor.whiteColor()
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
        df.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        df.timeZone = NSTimeZone(abbreviation: "PDT")
        df.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        let startofDay: NSDate = df.dateFromString("\(dateString) 00:00:00 PDT")!
        let endofDay: NSDate = df.dateFromString("\(dateString) 23:59:59 PDT")!
        
        //NSLog("Getting schedule for \(self.searchTerm)")
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.predicate = NSPredicate(format: "starred == YES AND begin >= %@ AND end <= %@", argumentArray: [startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.events = try! context.executeFetchRequest(fr)
        
        deHighlightAll()
        button.tintColor = toolBar.tintColor
        self.tableView.reloadData()
    }

    @IBAction func clearSchedule(sender: AnyObject) {
        let alert : UIAlertController = UIAlertController(title: "Clear Schedule", message: "Do you want to clear the viewed events from your schedule?", preferredStyle: UIAlertControllerStyle.Alert)
        let yesItem : UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) in
            var myEv:Event
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            for ev in self.events {
                myEv = ev as! Event
                myEv.starred = false
            }
            var err :NSError?
            do {
                try context.save()
            } catch let error as NSError {
                err = error
            } catch {
                fatalError()
            }
            if err != nil {
                NSLog("%@",err!)
            }
            self.events = []
            self.tableView.reloadData()
            
        })
        let noItem : UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) in
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
        let cell = tableView.dequeueReusableCellWithIdentifier("myEventCell", forIndexPath: indexPath) 

        let event : Event = self.events.objectAtIndex(indexPath.row) as! Event
        let df = NSDateFormatter()
        df.dateFormat = "EE HH:mm"
        df.timeZone = NSTimeZone(abbreviation: "PDT")
        df.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        let beginDate = df.stringFromDate(event.begin)
        df.dateFormat = "HH:mm"
        let endDate = df.stringFromDate(event.end)
        
        if (event.starred) {
            //NSLog("\(event.title) is starred!")
            cell.textLabel!.text = "** \(event.title) **"
            cell.textLabel!.textColor = self.highlightColor
        } else {
            cell.textLabel!.text = event.title
            cell.textLabel!.textColor = UIColor.whiteColor()
        }
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location))"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let myEvent : Event = self.events.objectAtIndex(indexPath.row) as! Event
        selectedEvent = myEvent
        self.performSegueWithIdentifier("myEventDetailSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "myEventDetailSegue") {
            let dv : HTEventDetailViewController = segue.destinationViewController as! HTEventDetailViewController
            dv.event = selectedEvent
        }
    }
    

}
