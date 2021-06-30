//
//  HTSearchTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/29/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class HTSearchTableViewController: UITableViewController, UISearchBarDelegate, EventDetailDelegate {

    @IBOutlet weak var eventSearchBar: UISearchBar!

    var filteredEvents: [UserEventModel] = []
    var allEvents: [UserEventModel] = []
    var eventsToken: UpdateToken?
    var st = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        eventsToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference!, descending: false) { (result) in
            switch result {
            case .success(let eventList):
                self.allEvents = eventList
                self.filterEvents()
            case .failure(_):
                NSLog("")
            }
        }

        tableView.register(UINib.init(nibName: "EventCell", bundle: Bundle(for: EventCell.self)), forCellReuseIdentifier: "EventCell")
        eventSearchBar.placeholder = "Search Events"
        eventSearchBar.delegate = self
        self.title = "Search"
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

        event = self.filteredEvents[indexPath.row]

        cell.bind(userEvent: event)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let storyboard = self.storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
            eventController.event = self.filteredEvents[indexPath.row].event
            eventController.bookmark = self.filteredEvents[indexPath.row].bookmark
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
        st = searchBar.text?.lowercased() ?? ""

        filterEvents()
    }

    func filterEvents() {
        var currentEvents: [UserEventModel] = []
        for e in allEvents {
            if e.event.title.lowercased().contains(st) {
                currentEvents.append(e)
            } else if e.event.description.lowercased().contains(st) {
                currentEvents.append(e)
            } else if e.event.location.name.lowercased().contains(st) {
                currentEvents.append(e)
            } else {
                for s in e.event.speakers {
                    if s.name.lowercased().contains(st) {
                        currentEvents.append(e)
                    }
                }
            }
        }
        self.filteredEvents = currentEvents
        self.tableView.reloadData()

    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        st = searchBar.text?.lowercased() ?? ""

        filterEvents()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.count > 0 {
            st = searchBar.text?.lowercased() ?? ""
        } else {
            self.filteredEvents = []
        }
        filterEvents()
    }

    func isFiltered() -> Bool {
        guard let text = eventSearchBar.text else {
            return false
        }

        return text.count > 0
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventDetailSegue" {

            let dv: HTEventDetailViewController

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

            dv.event = self.filteredEvents[indexPath.row].event
            dv.bookmark = self.filteredEvents[indexPath.row].bookmark
            dv.delegate = self
        }
    }
}
