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

    func getEventsFromSpeaker(_ indexsp: Int32) throws -> [Event] {
        var events = [Event]()
    
        let fre = NSFetchRequest<NSFetchRequestResult>(entityName:"EventSpeaker")
        fre.predicate = NSPredicate(format: "indexsp = %@", argumentArray: [indexsp])
        if let ret = try managedContext.fetch(fre) as? [EventSpeaker] {
            for es in ret {
                if let event = getEvent(es.index) {
                    events.append(event)
                }
            }
        }
        
        return events
    }
    
    func getEvent(_ index: Int32) -> Event? {
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fre.predicate = NSPredicate(format: "index = %@", argumentArray: [index])
       
        do {
            let ret = try managedContext.fetch(fre)
           
            return ret.first as? Event
        } catch {
            print("Failed to fetch event")
            return nil
        }
    }
    
    func getSpeaker(speakerId indexsp: Int32) -> Speaker? {
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Speaker")
        fre.predicate = NSPredicate(format: "indexsp = %@", argumentArray: [indexsp])
        
        do {
            let ret = try managedContext.fetch(fre)
            return ret.first as? Speaker
        } catch {
            print("Failed to fetch speaker")
            return nil
        }
        
    }
    
    func getSpeakersForEvent(_ index: Int32) -> [Speaker]? {
        var speakers: [Speaker] = []
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EventSpeaker")
        fre.predicate = NSPredicate(format: "index = %@", argumentArray: [index])
        
        
        do {
            let ret = try managedContext.fetch(fre) as? [EventSpeaker]
            
            if let eventSpeakers = ret {
                for es in eventSpeakers {
                    if let speaker = self.getSpeaker(speakerId: es.indexsp) {
                        speakers.append(speaker)
                    }
                }
                
                return speakers
            }
        } catch {
            print("failed to fetch speakers for event")
            return nil
        }
        
        return nil
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
