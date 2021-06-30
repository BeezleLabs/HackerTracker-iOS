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

    var vendorsToken: UpdateToken?
    var vendors: [HTVendorModel] = []

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
        if let url = URL(string: vendors[indexPath.row].link) {
            let svc = SFSafariViewController(url: url)
            svc.preferredBarTintColor = UIColor.backgroundGray
            svc.preferredControlTintColor = UIColor.white
            present(svc, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell", for: indexPath) as! UpdateCell

        var v: HTVendorModel

        v = self.vendors[indexPath.row]
        cell.bind(vendor: v)

        return cell
    }

    func loadVendors() {
        vendorsToken = FSConferenceDataController.shared.requestVendors(forConference: AnonymousSession.shared.currentConference, descending: false) { (result) in
            switch result {
            case .success(let vendorsList):
                self.vendors = vendorsList
                self.tableView.reloadData()
            case .failure(_):
                NSLog("")
            }
        }
    }

}
