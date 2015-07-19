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
    var searchTerm = ""
    var isFiltered:Bool = false
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var thursdayButton: UIBarButtonItem!
    var isThu:Bool = false
    @IBOutlet weak var fridayButton: UIBarButtonItem!
    var isFri:Bool = false
    @IBOutlet weak var saturdayButton: UIBarButtonItem!
    var isSat:Bool = false
    @IBOutlet weak var sundayButton: UIBarButtonItem!
    var isSun:Bool = false
    @IBOutlet weak var allButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var highlightColor = UIColor(red: 175.0, green: 236.0, blue: 68.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let font = UIFont(name: "Helvetica Neue", size: 12.0) {
            doneButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            thursdayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            fridayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            saturdayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            sundayButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            allButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
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
            var err:NSError? = nil


            //NSLog("Getting schedule for \(self.searchTerm)")
            fr.predicate = NSPredicate(format: "type = %@", argumentArray: [self.searchTerm])
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        //NSLog("have \(self.events.count) events to display")
        return self.events.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! UITableViewCell

        var event : Event = self.events.objectAtIndex(indexPath.row) as! Event
        let df = NSDateFormatter()
        df.dateFormat = "EE HH:mm"
        let beginDate = df.stringFromDate(event.begin)
        df.dateFormat = "HH:mm"
        let endDate = df.stringFromDate(event.end)
        
        cell.textLabel!.text = event.title
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location))"
        
        //NSLog("built cell for \(event.title)")

        return cell
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        fr.predicate = NSPredicate(format: "type = %@", argumentArray: [self.searchTerm])
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
        fr.predicate = NSPredicate(format: "type = %@ AND begin >= %@ AND end <= %@", argumentArray: [self.searchTerm, startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        var err:NSError? = nil
        self.events = context.executeFetchRequest(fr, error: &err)!

        deHighlightAll()
        button.tintColor = UIColor.greenColor()
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        NSLog("Search for \(searchText)")
        if (count(searchText) == 0) {
            isFiltered = false
        } else {
            isFiltered = true
            
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
            fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@ OR who contains[cd] %@", argumentArray: [searchText,searchText,searchText])
            var err:NSError? = nil
            self.events = context.executeFetchRequest(fr, error: &err)!
            
            self.tableView.reloadData()
            
        }
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
