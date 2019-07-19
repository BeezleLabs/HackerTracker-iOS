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
    var eventsToken : UpdateToken?

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

        self.tableView.reloadData()

        if let splitViewController = splitViewController,
            !splitViewController.isCollapsed {
            tableView.scrollToNearestSelectedRow(at: .middle, animated: true)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let characterCount = eventSearchBar.text?.count, characterCount > 0 {
            return self.filteredEvents.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
       
        var event: UserEventModel
        
        event = self.filteredEvents.object(at: indexPath.row) as! UserEventModel
        
        cell.bind(userEvent: event)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let storyboard = self.storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
            eventController.event = (self.filteredEvents.object(at: indexPath.row) as? UserEventModel)?.event
            eventController.bookmark = (self.filteredEvents.object(at: indexPath.row) as? UserEventModel)?.bookmark
            eventController.delegate = self
            self.navigationController?.pushViewController(eventController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        
        reloadEvents()
    }
    
    func filterEvents(_ searchText: String) {

        eventsToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference!) { (result) in
            switch result {
            case .success(let eventList):
                var currentEvents: [UserEventModel] = []
                for userEvent in eventList {
                    if userEvent.event.title.contains(searchText) {
                        currentEvents.append(userEvent)
                    } else if userEvent.event.description.contains(searchText) {
                        currentEvents.append(userEvent)
                    } else {
                        for s in userEvent.event.speakers {
                            if s.name.contains(searchText) {
                                currentEvents.append(userEvent)
                            }
                        }
                    }
                }
                self.filteredEvents = currentEvents as NSArray
                self.tableView.reloadData()
            case .failure(let _):
                NSLog("")
            }
            
        var currentEvents : Array<UserEventModel> = []
        self.filteredEvents = currentEvents as NSArray
 
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        
        filterEvents(searchText!)
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.count > 0) {
            filterEvents(searchText)
            
            self.tableView.reloadData()
        } else {
            self.filteredEvents = []
            self.tableView.reloadData()
        }
    }

    func isFiltered() -> Bool {
        guard let text = eventSearchBar.text else {
            return false
        }

        return text.count > 0
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

            dv.event = (self.filteredEvents.object(at: indexPath.row) as? UserEventModel)?.event
            dv.bookmark = (self.filteredEvents.object(at: indexPath.row) as? UserEventModel)?.bookmark
            dv.delegate = self
        }
    }
}
