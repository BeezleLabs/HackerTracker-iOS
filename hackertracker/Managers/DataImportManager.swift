//
//  DataImportManager.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/11/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import UIKit
import CoreData
class DataImportManager: NSObject {

    enum ImportError : Error {
        case idDoesntExist
    }
    let managedContext : NSManagedObjectContext
    
    public init(managedContext : NSManagedObjectContext) {
        self.managedContext = managedContext
        
        super.init()
    }
    
    public func importSpeakers(speakerData : Data) throws {
        let _speakers = try JSONSerialization.jsonObject(with: speakerData, options: .allowFragments) as? [String : Any]
        
        guard let speakers = _speakers, let updateDateString = speakers["update_date"] as? String, let _ = DateFormatterUtility.iso8601pdtFormatter.date(from:updateDateString), let speakerItems = speakers["speakers"] as? [[String : Any]] else
        {
            return ;
        }
        
        for speaker in speakerItems
        {
            if let _ = speaker["last_update"] as? String, let _ = speaker["indexsp"] as? String {
                do {
                    _ = try importSpeaker(speaker: speaker)
                } catch {
                    assert(false, "Failed to import speaker \(speaker)")
                    print("Failed to import speaker \(speaker)")
                }
            }
        }
    }
    
    public func importSpeaker(speaker : [String : Any]) throws -> Speaker {
        guard let indexString = speaker["indexsp"] as? String, let index = Int32(indexString) else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Speaker")
        fre.predicate = NSPredicate(format: "indexsp = %@", argumentArray: [index])
        
        let ret = try managedContext.fetch(fre)
        
        let managedSpeaker : Speaker
        
        if let existingSpeaker = ret.first as? Speaker {
            managedSpeaker = existingSpeaker
        } else {
            managedSpeaker = NSEntityDescription.insertNewObject(forEntityName: "Speaker", into: managedContext) as! Speaker
        }
        
        if let title = speaker["sptitle"] as? String {
            managedSpeaker.sptitle = title
        } else {
            managedSpeaker.sptitle = ""
        }
        
        if let who = speaker["who"] as? String {
            managedSpeaker.who = who
        } else {
            managedSpeaker.who = "Mystery Speaker"
        }
        
        managedSpeaker.indexsp = index
        
        if let lastUpdateString = speaker["last_update"] as? String, let lastUpdateDate =  DateFormatterUtility.iso8601pdtFormatter.date(from: lastUpdateString) {
            managedSpeaker.last_update = lastUpdateDate
        } else {
            managedSpeaker.last_update = Date()
        }
        
        if let media = speaker["media"] as? String {
            managedSpeaker.media = media
        } else {
            managedSpeaker.media = ""
        }
        
        if let bio = speaker["bio"] as? String {
            managedSpeaker.bio = bio
        } else {
            managedSpeaker.bio = ""
        }
        
        try managedContext.save()
        
        return managedSpeaker
        
    }

    public func importEvents(eventData : Data) throws {
        let _events = try JSONSerialization.jsonObject(with: eventData, options: .allowFragments) as? [String : Any]
        
        guard let events = _events, let updateDateString = events["update_date"] as? String, let lastUpdateDate = DateFormatterUtility.iso8601pdtFormatter.date(from:updateDateString), let eventItems = events["schedule"] as? [[String : Any]] else
        {
            return ;
        }
        
        for event in eventItems
        {
            if let _ = event["updated_at"] as? String, let _ = event["index"] {
                do {
                    _ = try importEvent(event: event)
                } catch let error {
                    print("Failed to import event \(event) error \(error)")
                }
            }
        }
        
        do {
            try setSyncDate(lastUpdateDate)
        } catch {
            assert(false, "Failed to save last update date")
            print("Failed to save last update date")
        }
    }
    
    public func importEvent(event : [String : Any]) throws -> Event {
        guard let indexString = event["index"] as? String, let index = Int32(indexString) else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fre.predicate = NSPredicate(format: "index = %@", argumentArray: [index])
        
        let ret = try managedContext.fetch(fre)
        
        let managedEvent : Event
        
        if let existingEvent = ret.first as? Event {
            managedEvent = existingEvent
            
        } else {
            managedEvent = NSEntityDescription.insertNewObject(forEntityName: "Event", into: managedContext) as! Event
            managedEvent.index = index
        }
        
        if let who = event["who"] as? [[String : Any]] {
            
            let speakersFetch:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EventSpeaker")
            speakersFetch.predicate = NSPredicate(format: "index = %@", argumentArray: [index])
            
            do {
                let speakerEvents = try managedContext.fetch(speakersFetch) as? [EventSpeaker]
                
                if let speakerEvents = speakerEvents {
                    for speakerEvent in speakerEvents {
                        managedContext.delete(speakerEvent)
                    }

                }
                
                try managedContext.save()
            } catch {
                assert(false, "Couldn't Fetch Speakers")
                print("Couldn't fetch speakers ignoring")
            }
            
            for eventData in who {
                if let speakerIDString = eventData["indexsp"] as? String, let speakerID = Int32(speakerIDString)
                {
                    do {
                        try setSpeakerEventPair(eventID: index, speakerID: speakerID)
                    } catch {
                        assert(false, "Failed to import Speaker")
                        print("Failed to import Speaker \(event)")
                    }
                }
            }
        }
        
        if let id = event["id"] as? String {
            managedEvent.id = id
        } else {
            managedEvent.id = ""
        }
        
        if let includes = event["includes"] as? String {
            managedEvent.includes = includes
        } else {
            managedEvent.includes = ""
        }
        
        if let title = event["title"] as? String {
            managedEvent.title = title
        } else {
            managedEvent.title = "TBD"
        }
        
        if let link = event["link"] as? String {
            managedEvent.link = link
        } else {
            managedEvent.link = ""
        }
        
        if let location = event["location"] as? String {
            managedEvent.location = location
        } else {
            managedEvent.location = ""
        }
        
        if let entryType = event["entry_type"] as? String {
            managedEvent.entry_type = entryType
        } else {
            managedEvent.entry_type = ""
        }
        
        if let description = event["description"] as? String {
            managedEvent.details = description
        } else {
            managedEvent.details = ""
        }
        
        if let startDateString = event["start_date"] as? String, let startDate =  DateFormatterUtility.iso8601pdtFormatter.date(from: startDateString) {
            managedEvent.start_date = startDate
        } else {
            managedEvent.start_date = DateFormatterUtility.iso8601pdtFormatter.date(from: "2017-07-25T10:00:00")!
        }
        
        if let endDateString = event["start_date"] as? String, let endDate =  DateFormatterUtility.iso8601pdtFormatter.date(from: endDateString) {
            managedEvent.end_date = endDate
        } else {
            managedEvent.end_date = DateFormatterUtility.iso8601pdtFormatter.date(from: "2017-07-25T10:00:00")!
        }
        
        if let lastUpdateString = event["last_update"] as? String, let lastUpdateDate =  DateFormatterUtility.iso8601pdtFormatter.date(from: lastUpdateString) {
            managedEvent.updated_at = lastUpdateDate
        } else {
            managedEvent.updated_at = Date()
        }
        
        if let recommendedString = event["recommended"] as? String, let recommendedInt = Int(recommendedString) {
            managedEvent.recommended = recommendedInt == 1
        } else {
            managedEvent.recommended = false
        }
                
        try managedContext.save()
        
        return managedEvent
    }
    
    public func lastSyncDate() -> Date? {
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
       
        let ret : [Any]
        
        do {
            ret = try managedContext.fetch(fr)
        } catch {
            return nil
        }
        
        if (ret.count > 0) {
            return (ret[0] as! Status).lastsync
        }
        
        return nil
    }
    
    func setSyncDate(_ date: Date) throws {
        
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
        let ret = try managedContext.fetch(fr)
        
        let managedStatus : Status
        
        if let firstStatus = ret.first as? Status {
            managedStatus = firstStatus
        } else {
            managedStatus = NSEntityDescription.insertNewObject(forEntityName: "Status", into: managedContext) as! Status
        }
        
        managedStatus.lastsync = date

        try managedContext.save()
    }
    
    func setSpeakerEventPair(eventID : Int32, speakerID : Int32) throws {
        let eventSpeaker = NSEntityDescription.insertNewObject(forEntityName: "EventSpeaker", into: managedContext) as! EventSpeaker
        
        eventSpeaker.index = eventID
        eventSpeaker.indexsp = speakerID
        
        try managedContext.save()
    }
    
}
