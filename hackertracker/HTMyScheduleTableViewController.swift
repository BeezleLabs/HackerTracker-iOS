//
//  HTMyScheduleTableViewController.swift
//  hackertracker
//
//  Created by Seth Law on 4/18/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTMyScheduleTableViewController: BaseScheduleTableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let font = UIFont(name: "Bungee", size: 24.0) else {
            NSLog("whoops")
            return
        }
        reloadEvents()
    }

    override func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        let startofDay: Date = DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 00:00:00 PDT")!
        let endofDay: Date = DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 23:59:59 PDT")!
        
        if let con = DataRequestManager(managedContext: getContext()).getSelectedConference() {
            fr.predicate = NSPredicate(format: "start_date >= %@ AND start_date <= %@ AND starred == YES AND conference = %@", argumentArray: [startofDay, endofDay,con])
            
        } else {
            fr.predicate = NSPredicate(format: "start_date >= %@ AND start_date <= %@ AND starred == YES", argumentArray: [startofDay, endofDay])
        }
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        return fr
    }

}
