//
//  ScheduleHelper.swift
//  hackertracker
//
//  Created by Seth Law on 6/11/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import Foundation
import CoreData


func updateSchedule(_ data: Data) -> Bool {
    
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext!
    
    let json = JSON(data: data, options: JSONSerialization.ReadingOptions.mutableLeaves, error: nil)
    
    let df = DateFormatterUtility.yearMonthDayNoTimeZoneTimeFormatter
    
    let updateTime = json["updateTime"].string!
    let updateDate = json["updateDate"].string!
    NSLog("schedule updated at \(updateDate) \(updateTime)")
    
    let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
    let status = ((try! context.fetch(fr)) as NSArray)[0] as! Status
    
    let syncDate = df.date(from: "\(updateDate) \(updateTime)")! as Date
    NSLog("syncDate: \(df.string(from: syncDate)), lastSync: \(df.string(from: status.lastsync))")
    
    var retBool: Bool = true
    
    if ( syncDate.compare(status.lastsync) == ComparisonResult.orderedDescending) {
        
        status.lastsync = syncDate
        
        let message2 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message2.date = syncDate
        let schedule = json["schedule"].array!
        message2.msg = "Schedule updated with \(schedule.count) events."
        
        NSLog("Total events: \(schedule.count)")
        
        var mySched : [Event] = []
        
        df.dateFormat = "yyyy-MM-dd HH:mm z"
        
        for item in schedule {
            let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
            fre.predicate = NSPredicate(format: "id = %@", argumentArray: [item["id"].stringValue])
            var events = try! context.fetch(fre)
            var te: Event
            if events.count > 0 {
                te = events[0] as! Event
            } else {
                te = NSEntityDescription.insertNewObject(forEntityName: "Event", into: context) as! Event
                te.id = item["id"].int32Value
                te.starred = false
            }
            
            te.who = item["who"].string!
            var d = item["date"].string!
            var b = item["begin"].string!
            var e = item["end"].string!
            if ( d == "" ) {
                d = "2016-08-04"
            }
            if ( b != "" ) {
                if ( b == "24:00") {
                    b = "00:00"
                    if ( d == "2016-08-04" ) {
                        d = "2016-08-05"
                    } else if ( d == "2016-08-05" ) {
                        d = "2016-08-06"
                    } else if ( d == "2016-08-06" ) {
                        d = "2016-08-07"
                    } else if ( d == "2016-08-07" ) {
                        d = "2016-08-08"
                    }
                }
                te.begin = df.date(from: "\(d) \(b) PDT")!
            } else {
                te.begin = df.date(from: "\(d) 00:00 PDT")!
            }
            if ( e != "" ) {
                if ( e == "24:00") {
                    e = "00:00"
                    if ( d == "2016-08-04" ) {
                        d = "2016-08-05"
                    } else if ( d == "2016-08-05" ) {
                        d = "2016-08-06"
                    } else if ( d == "2016-08-06" ) {
                        d = "2016-08-07"
                    } else if ( d == "2016-08-07" ) {
                        d = "2016-08-08"
                    }
                }
                te.end = df.date(from: "\(d) \(e) PDT")!
            } else {
                te.end = df.date(from: "\(d) 23:59 PDT")!
            }
            
            if (item["location"] != "") {
                te.location = item["location"].string!
            }
            
            if (item["title"] != "") {
                te.title = item["title"].string!
            }
            if item["description"] != "" {
                te.details = item["description"].string!
            }
            //NSLog("\(te.id): \(te.title) \(item["link"])")
            if ( item["link"] != JSON.null) {
                te.link = item["link"].string!
            }
            
            if (item["type"] != "") {
                te.type = item["type"].string!
            }
            
            if (item["demo"] != "") {
                te.demo = item["demo"].boolValue
            }
            
            if (item["tool"] != "") {
                te.tool = item["tool"].boolValue
            }
            
            if (item["exploit"] != "" ) {
                te.exploit = item["exploit"].boolValue
            }
            mySched.append(te)
        }
        
        
        var err:NSError? = nil
        do {
            try context.save()
        } catch let error as NSError {
            err = error
        }
        
        if let error = err {
            print(error)
        }
        
        NSLog("Schedule Updated")
    } else {
        NSLog("Schedule is up to date")
        retBool = false
    }
    
    return retBool
}

