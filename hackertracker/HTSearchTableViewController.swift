//
//  HTSearchTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/29/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTSearchTableViewController: UITableViewController, UISearchBarDelegate, EventDetailDelegate {
    
    @IBOutlet weak var eventSearchBar: UISearchBar!
    
    var filteredEvents:NSArray = []
    var selectedEvent:Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         tableView.register(UINib.init(nibName: "EventCell", bundle: Bundle(for: EventCell.self)), forCellReuseIdentifier: "EventCell")
        eventSearchBar.placeholder = "Search Events"
        eventSearchBar.delegate = self
        self.title = "SEARCH"
        tableView.keyboardDismissMode = .onDrag
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func reloadEvents() {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        var event: Event?

        if let selectedIndexPath = selectedIndexPath {
            event = filteredEvents[selectedIndexPath.row] as? Event
        }

        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let characterCount = eventSearchBar.text?.characters.count, characterCount > 0 {
            return self.filteredEvents.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
       
        var event: Event
        
        event = self.filteredEvents.object(at: indexPath.row) as! Event
        
        cell.bind(event: event)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "eventDetailSegue", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Search Bar Functions
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        
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

        fr.predicate = NSPredicate(format: "location contains[cd] %@ OR title contains[cd] %@ OR details contains[cd] %@ OR includes contains[cd] %@", argumentArray: [searchText,searchText, searchText, searchText])
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
        
        filterEvents(searchText!)
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.characters.count > 0) {
            filterEvents(searchText)
            
            self.tableView.reloadData()
        } else {
            self.filteredEvents = []
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "eventDetailSegue") {

            let dv : HTEventDetailViewController

            if let destinationNav = segue.destination as? UINavigationController, let _dv = destinationNav.viewControllers.first as? HTEventDetailViewController {
                dv = _dv
            } else {
                dv = segue.destination as! HTEventDetailViewController
            }

            var indexPath: IndexPath
            if let ec = sender as? EventCell {
                indexPath = tableView.indexPath(for: ec)! as IndexPath
            } else {
                indexPath = sender as! IndexPath
            }

            dv.event = self.filteredEvents.object(at: indexPath.row) as? Event
            dv.delegate = self
        }
    }
}
