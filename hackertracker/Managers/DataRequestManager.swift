//
//  DataRequestManager.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/12/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData

class DataRequestManager: NSObject {

    let managedContext : NSManagedObjectContext
    
    public init(managedContext : NSManagedObjectContext) {
        self.managedContext = managedContext
        
        super.init()
    }
    
    func getConference(_ code: String) -> Conference? {
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Conference")
        fre.predicate = NSPredicate(format: "code = %@", argumentArray: [code])
        
        do {
            let ret = try managedContext.fetch(fre)
            
            return ret.first as? Conference
        } catch {
            print("Failed to fetch conference")
            return nil
        }
    }
    
    func getConferences() -> [Conference] {
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Conference")
        
        do {
            let ret = try managedContext.fetch(fre) as! [Conference]
            
            return ret
        } catch {
            print("Failed to fetch conferences")
            return []
        }
    }
    
    func getConferenceDates(_ conference: Conference) -> [String] {
        let calendar = NSCalendar.current
        var ret: [String] = []
        
        let components = calendar.dateComponents([.day], from: conference.start_date!, to: conference.end_date!)
        ret.append(DateFormatterUtility.yearMonthDayFormatter.string(from: conference.start_date!))
        var cur = conference.start_date!
        for _ in 1...components.day! {
            cur = calendar.date(byAdding: Calendar.Component.day, value: 1, to: cur)!
            ret.append(DateFormatterUtility.yearMonthDayFormatter.string(from: cur))
        }
        return ret
    }
    
    func getSelectedConferences() -> [Conference] {
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Conference")
        fre.predicate = NSPredicate(format: "selected = true")
        
        do {
            let ret = try managedContext.fetch(fre) as! [Conference]
            
            return ret
        } catch {
            print("Failed to fetch conferences")
            return []
        }
    }
    
    func getSelectedConference() -> Conference? {
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Conference")
        fre.predicate = NSPredicate(format: "selected = true")
        
        do {
            let ret = try managedContext.fetch(fre) as! [Conference]
            
            return ret.first
        } catch {
            print("Failed to fetch conferences")
            return nil
        }
    }
    
    func getEventTypes(con: Conference) -> [EventType]{
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EventType")
        fre.predicate = NSPredicate(format: "conference = %@", argumentArray: [con])
        fre.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let ret = try managedContext.fetch(fre)
            return ret as! [EventType]
        } catch {
            print("Failed to fetch event types")
            return []
        }
        
    }
    
    func getEvent(_ id: Int32) -> Event? {
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
       
        do {
            let ret = try managedContext.fetch(fre)
           
            return ret.first as? Event
        } catch {
            print("Failed to fetch event")
            return nil
        }
    }
    
    func getSpeaker(speakerId id: Int32) -> Speaker? {
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Speaker")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        do {
            let ret = try managedContext.fetch(fre)
            return ret.first as? Speaker
        } catch {
            print("Failed to fetch speaker")
            return nil
        }
        
    }
    
    func getLocation(id: Int32) -> LocationModel? {
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"LocationModel")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        do {
            let ret = try managedContext.fetch(fre)
            return ret.first as? LocationModel
        } catch {
            print("Failed to fetch location")
            return nil
        }
        
    }
    
    func getEventType(id: Int32) -> EventType? {
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EventType")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        do {
            let ret = try managedContext.fetch(fre)
            return ret.first as? EventType
        } catch {
            print("Failed to fetch location")
            return nil
        }
        
    }
    
    func findConflictingStarredEvents(_ event: Event) -> [Event]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fr.predicate = NSPredicate(format: "start_date >= %@ AND end_date <= %@ AND starred == YES", argumentArray: [event.start_date, event.end_date])
        fr.sortDescriptors = [NSSortDescriptor(key: "start_date", ascending: true)]
        fr.returnsObjectsAsFaults = false
        
        do {
            let events = try managedContext.fetch(fr) as? [Event]
            return events
        } catch {
            return nil
        }
    }
    
}
