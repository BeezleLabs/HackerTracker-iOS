//
//  HTNewsTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 7/19/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTNewsTableViewController: UITableViewController {

    var articles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib.init(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        
        self.loadArticles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell", for: indexPath) as! UpdateCell
        
        var a: Article
        
        a = self.articles[indexPath.row]
        cell.bind(message: a)
        
        return cell
    }
    
    func loadArticles() {
        if let con = DataRequestManager(managedContext: getContext()).getSelectedConference() {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Article")
            fr.predicate = NSPredicate(format: "conference = %@", argumentArray: [con])
            fr.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
            fr.returnsObjectsAsFaults = false
            
            articles = try! getContext().fetch(fr) as! [Article]
        }
    }

}
