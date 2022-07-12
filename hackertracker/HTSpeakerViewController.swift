//
//  HTSpeakerViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/6/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import SafariServices
import UIKit

class HTSpeakerViewController: UIViewController, UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate, EventCellDelegate {
    @IBOutlet private var twitterButton: UIButton!
    @IBOutlet private var talkButton: UIButton!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var bioLabel: UILabel!
    @IBOutlet private var vertStackView: UIStackView!
    @IBOutlet private var eventTableView: UITableView!
    @IBOutlet private var eventTableHeightConstraint: NSLayoutConstraint!

    var eventTokens: [UpdateToken] = []
    var events: [UserEventModel] = []
    var speaker: HTSpeaker?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let speaker = speaker {
            nameLabel.text = speaker.name
            bioLabel.text = speaker.description
            bioLabel.sizeToFit()
            eventTableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
            eventTableView.register(UINib(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")

            eventTableView.delegate = self
            eventTableView.dataSource = self
            eventTableView.backgroundColor = UIColor.clear
            eventTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

            addEventList()

            twitterButton.isHidden = true
            if !speaker.twitter.isEmpty {
                twitterButton.setTitle(speaker.twitter, for: .normal)
                twitterButton.isHidden = false
            }

            self.eventTableView.reloadData()
            self.vertStackView.layoutSubviews()
        }
    }

    func addEventList() {
        var idx = 0
        for eventModel in speaker?.events ?? [] {
            if eventTokens.indices.contains(idx) {
                // NSLog("Already an eventtoken for event \(e.title)")
            } else {
                let eToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference, eventId: eventModel.id) { result in
                    switch result {
                    case .success(let event):
                        if self.events.contains(event), let idx = self.events.firstIndex(of: event) {
                            self.events.remove(at: idx)
                            self.events.insert(event, at: idx)
                        } else {
                            self.events.append(event)
                        }

                        self.eventTableView.reloadData()
                        self.vertStackView.layoutSubviews()

                    case .failure:
                        // TODO: Properly log failure
                        break
                    }
                }
                eventTokens.append(eToken)
            }
            idx += 1
        }
        if let speaker = speaker {
            if !speaker.events.isEmpty {
                eventTableHeightConstraint.constant = CGFloat(speaker.events.count * 200)
            } else {
                eventTableHeightConstraint.constant = 100
            }
        }
    }

    @IBAction private func twitterTapped(_ sender: Any) {
        if let twit = speaker?.twitter {
            if let url = URL(string: "https://mobile.twitter.com/\(twit.replacingOccurrences(of: "@", with: ""))") {
                let controller = SFSafariViewController(url: url)
                controller.preferredBarTintColor = .backgroundGray
                controller.preferredControlTintColor = .white
                present(controller, animated: true)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventSegue" {
            let destController: HTEventDetailViewController

            if let destinationNav = segue.destination as? UINavigationController, let controller = destinationNav.viewControllers.first as? HTEventDetailViewController {
                destController = controller
            } else {
                destController = segue.destination as! HTEventDetailViewController
            }

            if let speaker = speaker {
                let events = speaker.events
                if !events.isEmpty {
                    destController.event = events[0]
                }
            }
            destController.transitioningDelegate = self
        }
    }

    // Table Functions

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !events.isEmpty {
            return events.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !events.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            let event = events[indexPath.row]
            cell.bind(userEvent: event)
            cell.eventCellDelegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
            cell.bind(title: "404 - Not Found", desc: "No events found for this speaker, check with the #hackertracker team")
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let speaker = speaker, !speaker.events.isEmpty {
            let event: UserEventModel = events[indexPath.row]

            if let storyboard = self.storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
                eventController.event = event.event
                eventController.bookmark = event.bookmark
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(eventController, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Event Cell Delegate
    func updatedEvents() {
        // self.addEventList()
        self.eventTableView.reloadData()
    }
}
