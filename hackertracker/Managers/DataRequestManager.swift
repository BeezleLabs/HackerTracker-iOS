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
        let dfu = DateFormatterUtility.shared
        ret.append(dfu.yearMonthDayFormatter.string(from: conference.start_date!))
        var cur = conference.start_date!
        for _ in 1...components.day! {
            cur = calendar.date(byAdding: Calendar.Component.day, value: 1, to: cur)!
            ret.append(dfu.yearMonthDayFormatter.string(from: cur))
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
    
    func getConferenceMap(code: String) -> URL? {
        if let u = Bundle.main.url(forResource: "map", withExtension: "pdf", subdirectory: code){
            return u
        } else {
            let fm = FileManager.default
            let docDir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let u = docDir.appendingPathComponent("\(code)/map.pdf")
            if fm.fileExists(atPath: u.path) {
                return u
            } else {
                if fetchConferenceMap(code: code) {
                    return u
                }
            }
        }
        
        return nil
    }
    
    func fetchConferenceMap(code: String) -> Bool {
        let envPlist = Bundle.main.path(forResource: "Connections", ofType: "plist")
        let envs = NSDictionary(contentsOfFile: envPlist!)!
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mapFile = docDir.appendingPathComponent("\(code)/map.pdf")
        
        
        let base = envs.value(forKey: "base") as! String
        if let url = URL(string: "\(base)/\(code)/map.pdf"), let data = try? Data.init(contentsOf: url) {
            do {
                try data.write(to: mapFile, options: .atomic)
                print("map successfully saved!")
                return true

            } catch {
                print("map could not be saved")
                return false
            }
        }
        
        return false
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
        fr.predicate = NSPredicate(format: "start_date >= %@ AND end_date <= %@ AND starred == YES", argumentArray: [event.start_date!, event.end_date!])
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
