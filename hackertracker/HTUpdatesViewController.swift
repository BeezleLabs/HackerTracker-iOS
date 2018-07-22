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

class HTUpdatesViewController: UIViewController, EventDetailDelegate {

    @IBOutlet weak var updatesTableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var trailingImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var skullBackground: UIImageView!
    @IBOutlet weak var conName: UILabel!

    var messages: [Article] = []
    var eventSections: [String] = ["News","Upcoming Starred","Upcoming"]
    var starred: [Event] = []
    var upcoming: [Event] = []
    var data = NSMutableData()
    var myCon: Conference?
    
    var footer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        myCon = DataRequestManager(managedContext: context).getSelectedConference()
        conName.text = myCon?.name

        updatesTableView.rowHeight = UITableViewAutomaticDimension
        updatesTableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        updatesTableView.register(UINib.init(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        
        updatesTableView.delegate = self
        updatesTableView.dataSource = self
        updatesTableView.backgroundColor = UIColor.clear
        updatesTableView.contentInset = UIEdgeInsets(top: view.frame.size.height * 0.4, left: 0, bottom: 0, right: 0)
       
        if let footer = Bundle.main.loadNibNamed("ContributorsFooterView", owner: self, options: nil)?.first as? ContributorsFooterView {
            updatesTableView.tableFooterView = footer
            //var frame = updatesTableView.tableFooterView?.frame
            //frame?.size.height = view.frame.size.height * 0.25
            //updatesTableView.frame = frame ?? CGRect.zero
            //updatesTableView.tableFooterView = footer
            footer.footerDelegate = self
            self.footer = footer
        }
        reloadEvents()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.footer.frame.size.height = 360
        updatesTableView.tableFooterView = self.footer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        myCon = DataRequestManager(managedContext: context).getSelectedConference()
        conName.text = myCon?.name
        reloadEvents()
        
        self.updatesTableView.reloadData()
        self.updatesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.updatesTableView.separatorColor = UIColor.gray
        self.updatesTableView.separatorStyle = .singleLine
    }

    func reloadEvents() {
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Article")
        fr.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        if let c = myCon {
            fr.predicate = NSPredicate(format: "conference = %@", argumentArray: [c])
        }
        fr.returnsObjectsAsFaults = false
        fr.fetchLimit = 2
        self.messages = (try! getContext().fetch(fr)) as! [Article]
        
        let frs:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        frs.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        if let c = myCon {
            frs.predicate = NSPredicate(format: "conference = %@ and start_date > %@ and starred = %@", argumentArray: [c, Date(), true])
        }
        frs.returnsObjectsAsFaults = false
        frs.fetchLimit = 3
        self.starred = (try! getContext().fetch(frs)) as! [Event]
        
        let fru:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fru.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        if let c = myCon {
            fru.predicate = NSPredicate(format: "conference = %@ and start_date > %@", argumentArray: [c, Date(), true])
        }
        fru.returnsObjectsAsFaults = false
        fru.fetchLimit = 3
        self.upcoming = (try! getContext().fetch(fru)) as! [Event]

    }
}

extension HTUpdatesViewController : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventSections.count
        // News
        //
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
            
            cell.bind(message: messages[indexPath.row])
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            let event : Event = starred[indexPath.row]
            
            cell.bind(event: event)
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
            let event : Event = upcoming[indexPath.row]
            
            cell.bind(event: event)
            
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
            return messages.count
        } else if section == 1 {
            return starred.count
        } else if section == 2 {
            return upcoming.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 || indexPath.section == 2 {
            self.performSegue(withIdentifier: "homeEventDetailSegue", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeEventDetailSegue" {
            let dv : HTEventDetailViewController
            
            if let destinationNav = segue.destination as? UINavigationController, let _dv = destinationNav.viewControllers.first as? HTEventDetailViewController {
                dv = _dv
            } else {
                dv = segue.destination as! HTEventDetailViewController
            }
            
            if let indexPath = sender as? IndexPath {
                if indexPath.section == 1 {
                    dv.event = self.starred[indexPath.row]
                } else {
                    dv.event = self.upcoming[indexPath.row]
                }
            }
            
            dv.delegate = self
        }
    }

}

extension HTUpdatesViewController : ContributorsFooterDelegate {
    func linkTapped(link: LinkType) {
        var url : URL? = nil
        switch link {
        case .chrismays94:
            url = URL(string: "https://twitter.com/chrismays94")!
        case .imachumphries:
            url = URL(string: "https://twitter.com/imachumphries")!
        case .macerameg:
            url = URL(string: "https://twitter.com/macerameg")!
            break
        case .sethlaw:
            url = URL(string: "https://twitter.com/sethlaw")!
            break
        }
        
        if let url = url {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }

    }
}
