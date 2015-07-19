//
//  HTSpeakersTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/23/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTSpeakersTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var eventSearchBar: UISearchBar!
    
    var events:NSArray = []
    var filteredEvents:NSArray = []
    var selectedEvent:Event?
    var isFiltered:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        //NSLog("Getting full schedule")
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.predicate = NSPredicate(format: "type = 'Official' AND who != ''", argumentArray: nil)
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        var err:NSError? = nil
        self.events = context.executeFetchRequest(fr, error: &err)!
        
        self.tableView.reloadData()
        eventSearchBar.showsCancelButton = true
        eventSearchBar.delegate = self
        
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
        if (isFiltered) {
            return self.filteredEvents.count
        } else {
            return self.events.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! UITableViewCell
        
        var event : Event
        if (isFiltered) {
            event = self.filteredEvents.objectAtIndex(indexPath.row) as! Event
        } else {
            event = self.events.objectAtIndex(indexPath.row) as! Event
        }
        let df = NSDateFormatter()
        df.dateFormat = "EE HH:mm"
        let beginDate = df.stringFromDate(event.begin)
        df.dateFormat = "HH:mm"
        let endDate = df.stringFromDate(event.end)
        
        cell.textLabel!.text = event.title
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location)) "
        
        //NSLog("built cell for \(event.title)")
        
        return cell
    }
    
    // MARK: - Search Bar Functions
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        isFiltered = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        isFiltered = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        isFiltered = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
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
            self.filteredEvents = context.executeFetchRequest(fr, error: &err)!
            
            self.tableView.reloadData()
            
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //NSLog("Segue to speaker detail")
        if (segue.identifier == "searchDetailSegue") {
            var dv : HTEventDetailViewController = segue.destinationViewController as! HTEventDetailViewController
            let indexPath : NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            if isFiltered {
                dv.event = self.filteredEvents.objectAtIndex(indexPath.row) as! Event
            } else {
                dv.event = self.events.objectAtIndex(indexPath.row) as! Event
            }
        }
    }

}
