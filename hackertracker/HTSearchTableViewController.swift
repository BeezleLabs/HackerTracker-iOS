//
//  HTSearchTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 6/29/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit

class HTSearchTableViewController: UITableViewController, UISearchBarDelegate, EventDetailDelegate {
    @IBOutlet private var eventSearchBar: UISearchBar!

    var filteredEvents: [UserEventModel] = []
    var allEvents: [UserEventModel] = []
    var eventsToken: UpdateToken?
    var searchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        eventsToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference, descending: false) { result in
            switch result {
            case .success(let eventList):
                self.allEvents = eventList
                self.filterEvents()
            case .failure:
                // TODO: Properly log failure
                break
            }
        }

        tableView.register(UINib(nibName: "EventCell", bundle: Bundle(for: EventCell.self)), forCellReuseIdentifier: "EventCell")
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
        searchText = searchBar.text?.lowercased() ?? ""

        filterEvents()
    }

    func filterEvents() {
        var currentEvents: [UserEventModel] = []
        for userEvent in allEvents {
            if userEvent.event.title.lowercased().contains(searchText) {
                currentEvents.append(userEvent)
            } else if userEvent.event.description.lowercased().contains(searchText) {
                currentEvents.append(userEvent)
            } else if userEvent.event.location.name.lowercased().contains(searchText) {
                currentEvents.append(userEvent)
            } else {
                for speaker in userEvent.event.speakers where speaker.name.lowercased().contains(searchText) {
                    currentEvents.append(userEvent)
                }
            }
        }
        self.filteredEvents = currentEvents
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text?.lowercased() ?? ""

        filterEvents()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            self.searchText = searchBar.text?.lowercased() ?? ""
        } else {
            self.filteredEvents = []
        }
        filterEvents()
    }

    func isFiltered() -> Bool {
        guard let text = eventSearchBar.text else {
            return false
        }

        return !text.isEmpty
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventDetailSegue" {
            let destController: HTEventDetailViewController

            if let destinationNav = segue.destination as? UINavigationController, let controller = destinationNav.viewControllers.first as? HTEventDetailViewController {
                destController = controller
            } else {
                destController = segue.destination as! HTEventDetailViewController
            }

            var indexPath: IndexPath
            if let cell = sender as? EventCell, let cellIndexPath = tableView.indexPath(for: cell) {
                indexPath = cellIndexPath
            } else if let senderIndexPath = sender as? IndexPath {
                indexPath = senderIndexPath
            } else {
                return
            }

            destController.event = self.filteredEvents[indexPath.row].event
            destController.bookmark = self.filteredEvents[indexPath.row].bookmark
            destController.delegate = self
        }
    }
}
