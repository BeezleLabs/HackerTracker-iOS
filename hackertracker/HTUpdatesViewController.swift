//
//  HTUpdatesViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class HTUpdatesViewController: UIViewController, EventDetailDelegate, EventCellDelegate {

    @IBOutlet weak var updatesTableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var trailingImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var skullBackground: UIImageView!
    @IBOutlet weak var conName: UILabel!

    var messages: [Article] = []
    var eventSections: [String] = ["News", "Up Next On Schedule", "Up Next", "Live Now", "About"]
    var starred: [Event] = []
    var upcoming: [Event] = []
    var liveNow: [Event] = []
    var data = NSMutableData()
    var myCon: Conference?
    var lastContentOffset: CGPoint?
    var rick: Int = 0

    var footer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        if let con = DataRequestManager(managedContext: context).getSelectedConference() {
            if let name = con.name {
                self.title = name
            }
        }

        updatesTableView.rowHeight = UITableViewAutomaticDimension
        updatesTableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        updatesTableView.register(UINib.init(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        updatesTableView.register(UINib.init(nibName: "AboutCell", bundle: nil), forCellReuseIdentifier: "AboutCell")

        updatesTableView.delegate = self
        updatesTableView.dataSource = self
        updatesTableView.backgroundColor = UIColor.clear
        updatesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        reloadEvents()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatesTableView.tableFooterView = self.footer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isViewLoaded && !animated  {
            reloadEvents()

            if let lastContentOffset = lastContentOffset {
                updatesTableView.contentOffset = lastContentOffset
                updatesTableView.layoutIfNeeded()
            }
        }
    }

    func reloadEvents() {
        guard let myCon = DataRequestManager(managedContext: getContext()).getSelectedConference() else {
            NSLog("No conference selected")
            return
        }
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Article")
        fr.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        fr.predicate = NSPredicate(format: "conference = %@", argumentArray: [myCon])
        fr.returnsObjectsAsFaults = false
        fr.fetchLimit = 2
        self.messages = (try! getContext().fetch(fr)) as! [Article]

        let frs:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        frs.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        frs.predicate = NSPredicate(format: "conference = %@ and start_date > %@ and starred = %@", argumentArray: [myCon, Date(), true])
        frs.returnsObjectsAsFaults = false
        frs.fetchLimit = 3
        self.starred = (try! getContext().fetch(frs)) as! [Event]

        let fru:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fru.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fru.predicate = NSPredicate(format: "conference = %@ and start_date > %@", argumentArray: [myCon, Date()])
        fru.returnsObjectsAsFaults = false
        fru.fetchLimit = 3
        self.upcoming = (try! getContext().fetch(fru)) as! [Event]
        
        let curTime = Date()
        let frl:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        frl.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        frl.predicate = NSPredicate(format: "conference = %@ and start_date <= %@ and end_date >= %@", argumentArray: [myCon, curTime, curTime])
        frl.returnsObjectsAsFaults = false
        self.liveNow = (try! getContext().fetch(frl)) as! [Event]

    }
    
    func updatedEvents() {
        self.reloadEvents()
        updatesTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        lastContentOffset = self.updatesTableView.contentOffset
        if segue.identifier == "eventDetailSegue" {
            let dv : HTEventDetailViewController

            if let destinationNav = segue.destination as? UINavigationController, let _dv = destinationNav.viewControllers.first as? HTEventDetailViewController {
                dv = _dv
            } else {
                dv = segue.destination as! HTEventDetailViewController
            }

            if let indexPath = sender as? IndexPath {
                if indexPath.section == 1 {
                    dv.event = self.starred[indexPath.row]
                } else if indexPath.section == 2 {
                    dv.event = self.upcoming[indexPath.row]
                } else if indexPath.section == 3 {
                    dv.event = self.liveNow[indexPath.row]
                }
            }

            dv.delegate = self
        }
    }
}

extension HTUpdatesViewController : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventSections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
            if messages.count > 0 {
                cell.bind(message: messages[indexPath.row])
            } else {
                cell.bind(title: "No News is Good News", desc: "Or maybe you just need to update your database")
            }
            return cell
        } else if indexPath.section == 1 {
            if starred.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
                let event : Event = starred[indexPath.row]
                cell.bind(event: event)
                cell.eventCellDelegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
                cell.bind(title: "No Events", desc: "Explore #hackertracker and maybe you will find something interesting to attend. Tap the star to have the event show up here on the home screen and in your schedule of events.")
                return cell
            }

        } else if indexPath.section == 2 {
            if upcoming.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
                let event : Event = upcoming[indexPath.row]
                cell.bind(event: event)
                cell.eventCellDelegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
                cell.bind(title: "No Events", desc: "Is the conference cancelled?")
                return cell
            }

        } else if indexPath.section == 3 {
            if liveNow.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
                let event : Event = liveNow[indexPath.row]
                cell.bind(event: event)
                cell.eventCellDelegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
                cell.bind(title: "No Live Events", desc: "Hmmmm, maybe DEF CON got cancelled?")
                return cell
            }
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath) as! AboutCell
            if let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                cell.versionLabel.setTitle("Hackertracker iOS v\(v) (\(b))", for: UIControlState.normal)
            }
            cell.aboutDelegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()

        let headerLabel = UILabel(frame: CGRect(x: 25, y: 0, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "Larsseit", size: 14)
        headerLabel.textColor = UIColor.lightGray
        headerLabel.text = eventSections[section].uppercased()
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if messages.count > 0 {
                return messages.count
            } else {
                return 1
            }
            
        } else if section == 1 {
            if starred.count > 0 {
                return starred.count
            } else {
                return 1
            }
        } else if section == 2 {
            if upcoming.count > 0 {
                return upcoming.count
            } else {
                return 1
            }
        } else if section == 3 {
            if liveNow.count > 0 {
                return liveNow.count
            } else {
                return 1
            }
        } else if section == 4 {
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ( indexPath.section == 1 && starred.count > 0 )
            || ( indexPath.section == 2 && upcoming.count > 0 )
            || ( indexPath.section == 3 && liveNow.count > 0 ) {
            if let storyboard = self.storyboard, let eventController = storyboard.instantiateViewController(withIdentifier: "HTEventDetailViewController") as? HTEventDetailViewController {
                if indexPath.section == 1 {
                    eventController.event = self.starred[indexPath.row]
                } else if indexPath.section == 2 {
                    eventController.event = self.upcoming[indexPath.row]
                } else if indexPath.section == 3 {
                    eventController.event = self.liveNow[indexPath.row]
                }
                self.navigationController?.pushViewController(eventController, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

extension HTUpdatesViewController: AboutCellDelegate {
    func followUrl(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = UIColor.backgroundGray
        safariVC.preferredControlTintColor = UIColor.white
        present(safariVC, animated: true, completion: nil)
    }
}
