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

    var eventsToken: UpdateToken?
    var events: [UserEventModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        self.tableView.reloadData()
    }

    override func reloadEvents() {
        //super.reloadEvents()
      
        self.eventsToken = FSConferenceDataController.shared.requestEvents(forConference: AnonymousSession.shared.currentConference!, descending: false) { (result) in
            switch result {
            case .success(let eventsList):
                self.events.removeAll()
                self.eventSections.removeAll()
                let dfu = DateFormatterUtility.shared
                if let conference = AnonymousSession.shared.currentConference, let start = dfu.yearMonthDayFormatter.date(from: conference.startDate), let end = dfu.yearMonthDayFormatter.date(from: conference.endDate) {
                    
                    for day in dfu.getConferenceDates(start: start, end: end) {
                        var events: [UserEventModel] = []
                        let dayDate = dfu.yearMonthDayFormatter.date(from: day)!
                        let range = dayDate...(dayDate.addingTimeInterval(86400))
                        for e in eventsList {
                            if e.bookmark.value, range.contains(e.event.beginDate)  {
                                NSLog("Adding \(e.event.title) to this schedule")
                                events.append(e)
                            } else {
                                //NSLog("\(e.event.title) not bookmarked")
                            }
                        }
                        if events.count > 0 {
                            self.eventSections.append((date: day, events: events))
                        }
                    }
                    self.tableView.reloadData()
                }
                
            case .failure(let _):
                NSLog("")
            }
        }
       
    }
}
