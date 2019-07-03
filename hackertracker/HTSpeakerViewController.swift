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
    
    var speaker: Speaker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let s = speaker, let n = s.name, let d = s.desc {
            nameLabel.text = n
            bioLabel.text = d
            if let events = speaker?.events?.allObjects {
                if events.count > 0, let e = events[0] as? Event {
                    talkButton.titleLabel?.numberOfLines = 3
                    talkButton.titleLabel?.lineBreakMode = .byWordWrapping
                    talkButton.setTitle(e.title, for: UIControl.State.normal)
                } else {
                    talkButton.isHidden = true
                }
            }
            twitterButton.isHidden = true
            if let t = s.twitter {
                if t != "" {
                    twitterButton.setTitle(t, for: .normal)
                    twitterButton.isHidden = false
                }
            }
            
        }
        
        eventTableView.rowHeight = UITableView.automaticDimension
        eventTableView.register(UINib.init(nibName: "EventCell", bundle: nil),  forCellReuseIdentifier: "EventCell")
        eventTableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")

        eventTableView.delegate = self
        eventTableView.dataSource = self
        eventTableView.backgroundColor = UIColor.clear
        eventTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        eventTableView.reloadData()

        vertStackView.layoutSubviews()
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
            
            /*if let events = speaker?.events?.allObjects {
                if events.count > 0, let e = events[0] as? HTEventModel {
                    dv.event = e
                }
            }*/
            dv.transitioningDelegate = self
            
        }
    }
    
    // Table Functions

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let c = speaker?.events?.allObjects.count {
            return c
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let events = speaker?.events?.allObjects as? [HTEventModel], events.count > 0 {

            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            let event : HTEventModel = events[indexPath.row]
            cell.bind(event: event)
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
            cell.bind(title: "No Events", desc: "No events for this speaker, check with the #hackertracker team")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
