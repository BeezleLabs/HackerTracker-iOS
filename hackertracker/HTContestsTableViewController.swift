//
//  HTContestsTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 8/6/18.
//  Copyright © 2018 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTContestsTableViewController: BaseScheduleTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        let startofDay: Date = DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 00:00:00 PDT")!
        let endofDay: Date = DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 23:59:59 PDT")!
        
        if let con = DataRequestManager(managedContext: getContext()).getSelectedConference() {
            fr.predicate = NSPredicate(format: "start_date >= %@ AND start_date <= %@ AND event_type.name = 'Contest' AND conference = %@" , argumentArray: [startofDay, endofDay,con])
            
        } else {
            fr.predicate = NSPredicate(format: "start_date >= %@ AND start_date <= %@ AND event_type.name == 'Contest' AND end_date > %@", argumentArray: [startofDay, endofDay, Date()])
        }
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        return fr
    }

}
