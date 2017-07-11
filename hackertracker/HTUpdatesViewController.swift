//
//  HTUpdatesViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTUpdatesViewController: UIViewController {
    
    @IBOutlet weak var updatesTableView: UITableView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    var messages: [Message] = []
    var data = NSMutableData()
    var syncAlert = UIAlertController(title: nil, message: "Syncing...", preferredStyle: .alert)
    
    @IBOutlet weak var logoCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    
    
    let standardLogoHeight = CGFloat(118.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        updatesTableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        
        updatesTableView.delegate = self
        updatesTableView.dataSource = self
        updatesTableView.backgroundColor = UIColor.clear
        updatesTableView.contentInset = UIEdgeInsets(top: 296, left: 0, bottom: 0, right: 0)
        
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Message")
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        self.messages = (try! context.fetch(fr)) as! [Message]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatesTableView.contentInset = UIEdgeInsets(top: backgroundImage.frame.size.height - 64, left: 0, bottom: 0, right: 0)
    }
    
}

extension HTUpdatesViewController : UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") as! UpdateCell
        
        cell.bind(message: messages[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let minHeight = standardLogoHeight - 40
        let percentage = min(1.0 + (scrollView.contentOffset.y / scrollView.contentInset.top), 1.0)
        self.logoHeightConstraint.constant = standardLogoHeight - (minHeight * percentage)
        self.logoCenterYConstraint.constant = -((self.backgroundImage.frame.height / 2) - 38) * percentage

    }
}
