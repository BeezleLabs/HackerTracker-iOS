//
//  HTSpeakerViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/6/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import SafariServices

class HTSpeakerViewController: UIViewController, UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var talkButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var vertStackView: UIStackView!
    @IBOutlet weak var eventTableView: UITableView!
    
    var eventTokens : [UpdateToken<HTEventModel>] = []
    var events: [HTEventModel] = []
    var speaker: HTSpeaker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let s = speaker {
            let n = s.name
            let d = s.description
            nameLabel.text = n
            bioLabel.text = d
            eventTableView.register(UINib.init(nibName: "EventCell", bundle: nil),  forCellReuseIdentifier: "EventCell")
            eventTableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
            
            eventTableView.delegate = self
            eventTableView.dataSource = self
            eventTableView.backgroundColor = UIColor.clear
            eventTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            addEventList()
            
            twitterButton.isHidden = true
                if s.twitter != "" {
                    twitterButton.setTitle(s.twitter, for: .normal)
                    twitterButton.isHidden = false
                }

            
        }
    }
    
    func addEventList() {
        for e in speaker!.events {
            let eToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference, eventId: e.id) { (result) in
                switch result {
                case .success(let event):
                    self.events.append(event)
                    NSLog("Got \(event.title) \(event.id)")
                    self.eventTableView.reloadData()
                    self.vertStackView.layoutSubviews()
                    
                case .failure(let _):
                    NSLog("")
                }
                
            }
            eventTokens.append(eToken)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func twitterTapped(_ sender: Any) {
        if let twit = speaker?.twitter {
            let l = "https://mobile.twitter.com/\(twit.replacingOccurrences(of: "@", with: ""))"
            if let u = URL(string: l) {
                let svc = SFSafariViewController(url: u)
                svc.preferredBarTintColor = UIColor.backgroundGray
                svc.preferredControlTintColor = UIColor.white
                present(svc, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "eventSegue") {
            
            let dv : HTEventDetailViewController
            
            if let destinationNav = segue.destination as? UINavigationController, let _dv = destinationNav.viewControllers.first as? HTEventDetailViewController {
                dv = _dv
            } else {
                dv = segue.destination as! HTEventDetailViewController
            }
            
            if let s = speaker {
                let events = s.events
                if events.count > 0 {
                    dv.event = events[0]
                }
            }
            dv.transitioningDelegate = self
            
        }
    }
    
    // Table Functions

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (events.count > 0 ) {
            return events.count
        } else {
            NSLog("only one row")
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        NSLog("made it here")
        if events.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            let event : HTEventModel = events[indexPath.row]
            NSLog("adding cell for \(event.id)")
            cell.bind(event: event)
            return cell

        } else {
            NSLog("no events, adding the update cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
            cell.bind(title: "No Events", desc: "No events for this speaker, check with the #hackertracker team")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event : HTEventModel = events[indexPath.row]

        if let storyboard = self.storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
            eventController.event = event
            self.navigationController?.pushViewController(eventController, animated: true)
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
}
