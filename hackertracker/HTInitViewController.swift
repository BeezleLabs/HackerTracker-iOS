//
//  HTInitViewController.swift
//  hackertracker
//
//  Created by Seth Law on 3/30/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class HTInitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext!
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
        fr.returnsObjectsAsFaults = false
        
        let status = try! context.fetch(fr) as NSArray
        
        if status.count < 1 {
            // First time setup. Load pre-con JSON file included from DCIB.
            NSLog("Database not setup, preloading with initial schedule")
            self.loadData()
        } else {
            let df = DateFormatterUtility.yearMonthDayTimeFormatter
            let startofYear: Date = df.date(from: "2017-01-01 00:00:01 PDT")!
            
            let fre = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
            fre.predicate = NSPredicate(format: "start_date < %@", argumentArray: [startofYear])
            
            let frm = NSFetchRequest<NSFetchRequestResult>(entityName:"Message")
            frm.predicate = NSPredicate(format: "date < %@", argumentArray: [startofYear])
            
            var updated = false
            
            do {
                let events = try! context.fetch(fre)
                if events.count > 0 {
                    for res in events {
                        context.delete(res as! NSManagedObject)
                    }
                    updated = true
                    try context.save()
                    NSLog("Deleted \(events.count) events.")
                }
                
                let messages = try! context.fetch(frm)
                if messages.count > 0 {
                    for res in events {
                        context.delete(res as! NSManagedObject)
                    }
                    updated = true
                    try context.save()
                    NSLog("Deleted \(messages.count) messages.")
                }
                
            } catch {}
            
            if updated {
                self.loadData()
            }
        }

        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(HTInitViewController.go), userInfo: nil, repeats: false)
    }
    
    func loadData() {
        let context = getContext()
        
        let speakers_file = Bundle.main.path(forResource: "speakers", ofType: "json")!
        let speakers_content = try! String(contentsOfFile: speakers_file)
        let speakers_data = speakers_content.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        
        if (!updateSpeakers(speakers_data))
        {
            NSLog("Failed to load speakers")
        }
        
        let schedule_file = Bundle.main.path(forResource: "schedule-full", ofType: "json")!
        let schedule_content = try! NSString(contentsOfFile: schedule_file, encoding: String.Encoding.ascii.rawValue)
        let schedule_data = schedule_content.data(using: String.Encoding.utf8.rawValue)!
        
        if (!updateSchedule(schedule_data)) {
            NSLog("Failed to load schedule")
        }
        
        let message1 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message1.date = Date()
        message1.msg = "Welcome to HackerTracker iOS for DEF CON 25. If you have any events, parties, or contests to add, or if you find any errors or typos, email info@beezle.org. The HackerTracker team is now a part of the DEF CON Infobooth. Code for this app can be found at https://github.com/BeezleLabs/HackerTracker-iOS."
        
        let message2 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message2.date = Date()
        message2.msg = "The initial schedule contains official talks, workshops, villages, parties, etc. Pull down on the schedule to update with info.defcon.org."
        
        do {
            try getContext().save()
        } catch let error as NSError {
            NSLog("error: \(error)")
        }
        
    }
    
    func go() {
        self.performSegue(withIdentifier: "HTHomeSegue", sender: self)
    }
}
