//
//  HTSpeakersTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/23/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTSpeakersTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var eventSearchBar: UISearchBar!
    
    var events:NSArray = []
    var filteredEvents:NSArray = []
    var selectedEvent:Event?
    var isFiltered:Bool = false
    
    let highlightColor = UIColor(red: 120/255.0, green: 114/255.0, blue: 255/255.0, alpha: 1)
    
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
        self.events = try! context.executeFetchRequest(fr)
        
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
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) 
        
        var event : Event
        if (isFiltered) {
            event = self.filteredEvents.objectAtIndex(indexPath.row) as! Event
        } else {
            event = self.events.objectAtIndex(indexPath.row) as! Event
        }
        let df = NSDateFormatter()
        df.dateFormat = "EE HH:mm"
        df.timeZone = NSTimeZone(abbreviation: "PDT")
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
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location)) "
        
        //NSLog("built cell for \(event.title)")
        
        return cell
    }
    
    // MARK: - Search Bar Functions
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        isFiltered = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        let searchText = searchBar.text
        if (searchText!.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
        }
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@ OR who contains[cd] %@", argumentArray: [searchText!,searchText!,searchText!])
        self.filteredEvents = try! context.executeFetchRequest(fr)
        
        self.tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchText = searchBar.text
        if (searchText!.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
        }
        
        let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@ OR who contains[cd] %@", argumentArray: [searchText!,searchText!,searchText!])
        self.filteredEvents = try! context.executeFetchRequest(fr)
        
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
            
            let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr:NSFetchRequest = NSFetchRequest(entityName:"Event")
            fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@ OR who contains[cd] %@", argumentArray: [searchText,searchText,searchText])
            self.filteredEvents = try! context.executeFetchRequest(fr)
            
            self.tableView.reloadData()
            
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //NSLog("Segue to speaker detail")
        if (segue.identifier == "searchDetailSegue") {
            let dv : HTEventDetailViewController = segue.destinationViewController as! HTEventDetailViewController
            let indexPath : NSIndexPath = self.tableView.indexPathForCell(sender as! UITableViewCell)!
            if isFiltered {
                dv.event = self.filteredEvents.objectAtIndex(indexPath.row) as! Event
            } else {
                dv.event = self.events.objectAtIndex(indexPath.row) as! Event
            }
        }
    }

}
