//
//  HTVendorTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/27/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class HTVendorTableViewController: UITableViewController {

    var vendors: [Vendor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        
        self.loadVendors()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendors.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let l = vendors[indexPath.row].link {
            if let u = URL(string: l) {
                let svc = SFSafariViewController(url: u)
                svc.preferredBarTintColor = UIColor.backgroundGray
                svc.preferredControlTintColor = UIColor.white
                present(svc, animated: true, completion: nil)
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell", for: indexPath) as! UpdateCell
        
        var v: Vendor
        
        v = self.vendors[indexPath.row]
        cell.bind(vendor: v)
        
        return cell
    }
    
    func loadVendors() {
        if let con = DataRequestManager(managedContext: getContext()).getSelectedConference() {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Vendor")
            fr.predicate = NSPredicate(format: "conference = %@", argumentArray: [con])
            fr.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: true)]
            fr.returnsObjectsAsFaults = false
            
            vendors = try! getContext().fetch(fr) as! [Vendor]
        }
    }

}
