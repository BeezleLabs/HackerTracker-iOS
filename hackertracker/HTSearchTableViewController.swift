//
//  HTSearchTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/29/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var eventSearchBar: UISearchBar!
    
    var events:NSArray = []
    var filteredEvents:NSArray = []
    var selectedEvent:Event?
    var isFiltered:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         tableView.register(UINib.init(nibName: "EventCell", bundle: Bundle(for: EventCell.self)), forCellReuseIdentifier: "EventCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.events = try! context.fetch(fr) as NSArray
        
        self.tableView.reloadData()
        eventSearchBar.delegate = self
        self.title = "SEARCH"
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltered) {
            return self.filteredEvents.count
        } else {
            return self.events.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
       
        var event: Event
        
        if (isFiltered) {
            event = self.filteredEvents.object(at: indexPath.row) as! Event
        } else {
            event = self.events.object(at: indexPath.row) as! Event
        }
        
        cell.bind(event: event)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "eventDetailSegue", sender: indexPath)
    }
    
    // MARK: - Search Bar Functions
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isFiltered = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        if (searchText!.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
        }
        
        filterEvents(searchText!)
        
        self.tableView.reloadData()
        
    }
    
    func filterEvents(_ searchText: String) {
        let context = getContext()
        
        var currentEvents : Array<Event> = []
        
        let dataRequest = DataRequestManager(managedContext: getContext())
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false

        fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@", argumentArray: [searchText,searchText])
        currentEvents = try! context.fetch(fr) as! Array<Event>
        
        let frs = NSFetchRequest<NSFetchRequestResult>(entityName:"Speaker")
        frs.returnsObjectsAsFaults = false
        frs.predicate = NSPredicate(format: "who contains[cd] %@", argumentArray: [searchText])
        let ret = try! context.fetch(frs) as NSArray
        if (ret.count > 0) {
            for s in ret {
                
                do {
                    let events = try dataRequest.getEventsFromSpeaker((s as! Speaker).indexsp)
                    for e in events {
                        currentEvents.append(e)
                    }
                } catch {
                    
                }
                
            }
        }
        
        self.filteredEvents = currentEvents as NSArray
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        if (searchText!.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
        }
        
        filterEvents(searchText!)
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.characters.count == 0) {
            isFiltered = false
        } else {
            isFiltered = true
            
            filterEvents(searchText)
            
            self.tableView.reloadData()
            
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "eventDetailSegue") {
            let dv : HTEventDetailViewController = segue.destination as! HTEventDetailViewController
            if let indexPath = sender as? IndexPath {
                if isFiltered {
                    dv.event = self.filteredEvents.object(at: indexPath.row) as? Event
                } else {
                    dv.event = self.events.object(at: indexPath.row) as? Event
                }
            }
        }
    }
}
