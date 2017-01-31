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

    override func fetchRequestForDay(_ dateString: String) -> NSFetchRequest<NSFetchRequestResult> {
        let startofDay: Date = DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 00:00:00 PDT")!
        let endofDay: Date = DateFormatterUtility.yearMonthDayTimeFormatter.date(from: "\(dateString) 23:59:59 PDT")!

        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "begin >= %@ AND end <= %@ AND starred == YES", argumentArray: [startofDay, endofDay])
        fr.sortDescriptors = [NSSortDescriptor(key: "begin", ascending: true)]
        fr.returnsObjectsAsFaults = false

        return fr
    }
}
