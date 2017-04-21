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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        //NSLog("Getting full schedule")
        
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "type = 'Official' AND who != ''", argumentArray: nil)
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.events = try! context.fetch(fr) as NSArray
        
        self.tableView.reloadData()
        eventSearchBar.showsCancelButton = true
        eventSearchBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset.top = 22
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // NSLog("have \(self.events.count) events to display")
        if (isFiltered) {
            return self.filteredEvents.count
        } else {
            return self.events.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) 
        
        var event : Event
        if (isFiltered) {
            event = self.filteredEvents.object(at: indexPath.row) as! Event
        } else {
            event = self.events.object(at: indexPath.row) as! Event
        }
        let df = DateFormatter()
        df.dateFormat = "EE HH:mm"
        df.timeZone = TimeZone(abbreviation: "PDT")
        df.locale = Locale(identifier: "en_US_POSIX")

        let beginDate = df.string(from: event.begin as Date)
        df.dateFormat = "HH:mm"
        let endDate = df.string(from: event.end as Date)
        
        if (event.starred) {
            //NSLog("\(event.title) is starred!")
            cell.textLabel!.text = "** \(event.title) **"
            cell.textLabel!.textColor = self.highlightColor
        } else {
            cell.textLabel!.text = event.title
            cell.textLabel!.textColor = UIColor.white
        }
        cell.detailTextLabel!.text = "\(beginDate)-\(endDate) (\(event.location)) "
        
        //NSLog("built cell for \(event.title)")
        
        return cell
    }
    
    // MARK: - Search Bar Functions
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isFiltered = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        if (searchText!.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
        }
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@ OR who contains[cd] %@", argumentArray: [searchText!,searchText!,searchText!])
        self.filteredEvents = try! context.fetch(fr) as NSArray
        
        self.tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        if (searchText!.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
        }
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false
        fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@ OR who contains[cd] %@", argumentArray: [searchText!,searchText!,searchText!])
        self.filteredEvents = try! context.fetch(fr) as NSArray
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
            
            let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.managedObjectContext!
            
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
            fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
            fr.returnsObjectsAsFaults = false
            fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@ OR who contains[cd] %@", argumentArray: [searchText,searchText,searchText])
            self.filteredEvents = try! context.fetch(fr) as NSArray
            
            self.tableView.reloadData()
            
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //NSLog("Segue to speaker detail")
        if (segue.identifier == "searchDetailSegue") {
            let dv : HTEventDetailViewController = segue.destination as! HTEventDetailViewController
            let indexPath : IndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            if isFiltered {
                dv.event = self.filteredEvents.object(at: indexPath.row) as? Event
            } else {
                dv.event = self.events.object(at: indexPath.row) as? Event
            }
        }
    }

}
