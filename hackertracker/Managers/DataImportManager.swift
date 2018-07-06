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
    let dataManager : DataRequestManager
    
    public init(managedContext : NSManagedObjectContext) {
        self.managedContext = managedContext
        self.dataManager = DataRequestManager(managedContext: self.managedContext)
        super.init()
    }
    
    public func importArticles(items : [[String : Any]]) throws {
        print("import after json decode")
        for i in items
        {
            if let _ = i["updated_at"] as? String, let _ = i["id"] as? Int32 {
                do {
                    _ = try importArticle(input: i)
                } catch {
                    assert(false, "Failed to import \(i)")
                    print("Failed to import \(i)")
                }
            }
        }
    }
    
    public func importArticle(input : [String : Any]) throws -> Article {
        guard let id = input["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Article")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fre)
        
        let managedItem : Article
        
        if let existingItem = ret.first as? Article {
            managedItem = existingItem
        } else {
            managedItem = NSEntityDescription.insertNewObject(forEntityName: "Article", into: managedContext) as! Article
        }
        
        if let code = input["conference"] as? String, let conference = self.dataManager.getConference(code) {
            managedItem.conference = conference
        }
        
        managedItem.id = id
        
        if let name = input["name"] as? String {
            managedItem.name = name
        } else {
            managedItem.name = ""
        }
        
        if let text = input["text"] as? String {
            managedItem.text = text
        } else {
            managedItem.text = ""
        }
        
        if let lastUpdateString = input["updated_at"] as? String, let updated_at =  DateFormatterUtility.iso8601Formatter.date(from: lastUpdateString) {
            managedItem.updated_at = updated_at
        } else {
            managedItem.updated_at = Date()
        }
        
        try managedContext.save()
        
        return managedItem
    }

    public func importEventTypes(items : [[String : Any]]) throws {
        for i in items
        {
            if let _ = i["updated_at"] as? String, let _ = i["id"] as? Int32 {
                do {
                    _ = try importEventType(input: i)
                } catch {
                    assert(false, "Failed to import \(i)")
                    print("Failed to import \(i)")
                }
            }
        }
    }
    
    public func importEventType(input : [String : Any]) throws -> EventType {
        guard let id = input["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EventType")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fre)
        
        let managedItem : EventType
        
        if let existingItem = ret.first as? EventType {
            managedItem = existingItem
        } else {
            managedItem = NSEntityDescription.insertNewObject(forEntityName: "EventType", into: managedContext) as! EventType
        }
        
        if let color = input["color"] as? String {
            managedItem.color = color
        } else {
            managedItem.color = ""
        }
        
        if let code = input["conference"] as? String, let conference = self.dataManager.getConference(code) {
            managedItem.conference = conference
        }
        
        managedItem.id = id
        
        if let name = input["name"] as? String {
            managedItem.name = name
        } else {
            managedItem.name = ""
        }
        
        if let lastUpdateString = input["updated_at"] as? String, let updated_at =  DateFormatterUtility.iso8601Formatter.date(from: lastUpdateString) {
            managedItem.updated_at = updated_at
        } else {
            managedItem.updated_at = Date()
        }
        
        try managedContext.save()
        
        return managedItem
    }

    public func importFAQs(items : [[String : Any]]) throws {
        for i in items
        {
            if let _ = i["updated_at"] as? String, let _ = i["id"] as? Int32 {
                do {
                    _ = try importFAQ(input: i)
                } catch {
                    assert(false, "Failed to import \(i)")
                    print("Failed to import \(i)")
                }
            }
        }
    }
    
    public func importFAQ(input : [String : Any]) throws -> FAQ {
        guard let id = input["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"FAQ")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fre)
        
        let managedItem : FAQ
        
        if let existingItem = ret.first as? FAQ {
            managedItem = existingItem
        } else {
            managedItem = NSEntityDescription.insertNewObject(forEntityName: "FAQ", into: managedContext) as! FAQ
        }
        
        if let answer = input["answer"] as? String {
            managedItem.answer = answer
        } else {
            managedItem.answer = ""
        }
        
        if let code = input["conference"] as? String, let conference = self.dataManager.getConference(code) {
            managedItem.conference = conference
        }
        
        managedItem.id = id
        
        if let question = input["question"] as? String {
            managedItem.question = question
        } else {
            managedItem.question = ""
        }
        
        if let lastUpdateString = input["updated_at"] as? String, let updated_at =  DateFormatterUtility.iso8601Formatter.date(from: lastUpdateString) {
            managedItem.updated_at = updated_at
        } else {
            managedItem.updated_at = Date()
        }
        
        try managedContext.save()
        
        return managedItem
    }
    
    public func importLocations(items : [[String : Any]]) throws {
        for i in items
        {
            if let _ = i["updated_at"] as? String, let _ = i["id"] as? Int32 {
                do {
                    _ = try importLocation(input: i)
                } catch {
                    assert(false, "Failed to import \(i)")
                    print("Failed to import \(i)")
                }
            }
        }
    }
    
    public func importLocation(input : [String : Any]) throws -> LocationModel {
        guard let id = input["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"LocationModel")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fre)
        
        let managedItem : LocationModel
        
        if let existingItem = ret.first as? LocationModel {
            managedItem = existingItem
        } else {
            managedItem = NSEntityDescription.insertNewObject(forEntityName: "LocationModel", into: managedContext) as! LocationModel
        }
        
        if let code = input["conference"] as? String, let conference = self.dataManager.getConference(code) {
            managedItem.conference = conference
        }

        managedItem.id = id
        
        if let name = input["name"] as? String {
            managedItem.name = name
        } else {
            managedItem.name = ""
        }
        
        if let lastUpdateString = input["updated_at"] as? String, let updated_at =  DateFormatterUtility.iso8601Formatter.date(from: lastUpdateString) {
            managedItem.updated_at = updated_at
        } else {
            managedItem.updated_at = Date()
        }
        
        try managedContext.save()
        
        return managedItem
    }
    
    public func importNotifications(items : [[String : Any]]) throws {
        for i in items
        {
            if let _ = i["updated_at"] as? String, let _ = i["id"] as? Int32 {
                do {
                    _ = try importNotification(input: i)
                } catch {
                    assert(false, "Failed to import \(i)")
                    print("Failed to import \(i)")
                }
            }
        }
    }
    
    public func importNotification(input : [String : Any]) throws -> Notification {
        guard let id = input["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Notification")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fre)
        
        let managedItem : Notification
        
        if let existingItem = ret.first as? Notification {
            managedItem = existingItem
        } else {
            managedItem = NSEntityDescription.insertNewObject(forEntityName: "Notification", into: managedContext) as! Notification
        }
        
        if let code = input["conference"] as? String, let conference = self.dataManager.getConference(code) {
            managedItem.conference = conference
        }
        
        managedItem.id = id
        
        if let text = input["text"] as? String {
            managedItem.text = text
        } else {
            managedItem.text = ""
        }
        
        if let _time = input["time"] as? String, let time =  DateFormatterUtility.iso8601Formatter.date(from: _time) {
            managedItem.time = time
        } else {
            managedItem.time = Date()
        }
        
        if let lastUpdateString = input["updated_at"] as? String, let updated_at =  DateFormatterUtility.iso8601Formatter.date(from: lastUpdateString) {
            managedItem.updated_at = updated_at
        } else {
            managedItem.updated_at = Date()
        }
        
        try managedContext.save()
        
        return managedItem
    }
    
    public func importVendors(items : [[String : Any]]) throws {
        for i in items
        {
            if let _ = i["updated_at"] as? String, let _ = i["id"] as? Int32 {
                do {
                    _ = try importVendor(input: i)
                } catch {
                    assert(false, "Failed to import \(i)")
                    print("Failed to import \(i)")
                }
            }
        }
    }
    
    public func importVendor(input : [String : Any]) throws -> Vendor {
        guard let id = input["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Vendor")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fre)
        
        let managedItem : Vendor
        
        if let existingItem = ret.first as? Vendor {
            managedItem = existingItem
        } else {
            managedItem = NSEntityDescription.insertNewObject(forEntityName: "Vendor", into: managedContext) as! Vendor
        }
        
        if let code = input["conference"] as? String, let conference = self.dataManager.getConference(code) {
            managedItem.conference = conference
        }
        
        if let desc = input["description"] as? String {
            managedItem.desc = desc
        } else {
            managedItem.desc = ""
        }
        
        managedItem.id = id
        
        if let link = input["link"] as? String {
            managedItem.link = link
        } else {
            managedItem.link = ""
        }
        
        if let name = input["name"] as? String {
            managedItem.name = name
        } else {
            managedItem.name = ""
        }
        
        if let partner = input["partner"] as? Bool {
            managedItem.partner = partner
        } else {
            managedItem.partner = false
        }
        
        if let lastUpdateString = input["updated_at"] as? String, let updated_at =  DateFormatterUtility.iso8601Formatter.date(from: lastUpdateString) {
            managedItem.updated_at = updated_at
        } else {
            managedItem.updated_at = Date()
        }
        
        try managedContext.save()
        
        return managedItem
    }
    
    public func importSpeakers(items : [[String : Any]]) throws {
        for i in items
        {
            if let _ = i["updated_at"] as? String, let _ = i["id"] as? Int32 {
                do {
                    _ = try importSpeaker(speaker: i)
                } catch {
                    assert(false, "Failed to import speaker \(i)")
                    print("Failed to import speaker \(i)")
                }
            }
        }
    }
    
    public func importSpeaker(speaker : [String : Any]) throws -> Speaker {
        guard let id = speaker["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Speaker")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fre)
        
        let managedSpeaker : Speaker
        
        if let existingSpeaker = ret.first as? Speaker {
            //print("Existing Speaker \(index)")
            managedSpeaker = existingSpeaker
        } else {
            managedSpeaker = NSEntityDescription.insertNewObject(forEntityName: "Speaker", into: managedContext) as! Speaker
        }
        
        if let code = speaker["conference"] as? String, let conference = self.dataManager.getConference(code) {
            managedSpeaker.conference = conference
        }
        
        if let desc = speaker["description"] as? String {
            managedSpeaker.desc = desc
        } else {
            managedSpeaker.desc = ""
        }
        
        managedSpeaker.id = id
        
        if let link = speaker["link"] as? String {
            managedSpeaker.link = link
        } else {
            managedSpeaker.link = ""
        }
        
        if let name = speaker["name"] as? String {
            managedSpeaker.name = name
        } else {
            managedSpeaker.name = "Mystery Speaker"
        }
        
        if let title = speaker["title"] as? String {
            managedSpeaker.title = title
        } else {
            managedSpeaker.title = ""
        }
       
        if let twitter = speaker["twitter"] as? String {
            managedSpeaker.twitter = twitter
        } else {
            managedSpeaker.twitter = ""
        }
        
        if let lastUpdateString = speaker["updated_at"] as? String, let updated_at =  DateFormatterUtility.iso8601Formatter.date(from: lastUpdateString) {
            managedSpeaker.updated_at = updated_at
        } else {
            managedSpeaker.updated_at = Date()
        }
        
        try managedContext.save()
        
        return managedSpeaker
    }

    public func importEvents(items : [[String : Any]]) throws {
        for i in items
        {
            if let _ = i["updated_at"] as? String, let _ = i["id"] {
                do {
                    _ = try importEvent(event: i)
                } catch let error {
                    print("Failed to import event \(i) error \(error)")
                }
            }
        }
        
    }
    
    public func importEvent(event : [String : Any]) throws -> Event {
        guard let id = event["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
        fre.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fre)
        
        let managedEvent : Event
        
        if let existingEvent = ret.first as? Event {
            managedEvent = existingEvent
        } else {
            managedEvent = NSEntityDescription.insertNewObject(forEntityName: "Event", into: managedContext) as! Event
            managedEvent.id = id
            managedEvent.starred = false
        }
        
        if let code = event["conference"] as? String, let conference = self.dataManager.getConference(code) {
            managedEvent.conference = conference
        }
        
        if var description = event["description"] as? String {
            if description.localizedCaseInsensitiveContains("Apple") {
                description = description.replacingOccurrences(of: "Apple", with: "[COMPANY X]")
                description = description.replacingOccurrences(of: "apple", with: "[COMPANY X]")
            }
            
            if description.localizedCaseInsensitiveContains("watchOS") {
                description = description.replacingOccurrences(of: "watchOS", with: "[OPERATING SYSTEM]")
            }
            
            if description.localizedCaseInsensitiveContains("macOS") {
                description = description.replacingOccurrences(of: "macOS", with: "[DESKTOP OPERATING SYSTEM]")
            }
            
            if description.localizedCaseInsensitiveContains("OSX") {
                description = description.replacingOccurrences(of: "OSX", with: "[DESKTOP OPERATING SYSTEM]")
            }
            
            if description.localizedCaseInsensitiveContains("OS X") {
                description = description.replacingOccurrences(of: "OS X", with: "[DESKTOP OPERATING SYSTEM]")
            }
            
            if description.localizedCaseInsensitiveContains("iOS") {
                description = description.replacingOccurrences(of: "iOS", with: "[MOBILE OPERATING SYSTEM]")
            }
            
            if description.localizedCaseInsensitiveContains("jailbreak") {
                description = description.replacingOccurrences(of: "jailbreak", with: "[CENSORED]")
                description = description.replacingOccurrences(of: "Jailbreak", with: "[CENSORED]")
            }
            
            if description.localizedCaseInsensitiveContains("jail break") {
                description = description.replacingOccurrences(of: "jail break", with: "[CENSORED]")
                description = description.replacingOccurrences(of: "Jail Break", with: "[CENSORED]")
            }
            
            managedEvent.desc = description
        } else {
            managedEvent.desc = ""
        }
        
        if let endDateString = event["end_date"] as? String, let endDate =  DateFormatterUtility.iso8601Formatter.date(from: endDateString) {
            managedEvent.end_date = endDate
        } else {
            managedEvent.end_date = DateFormatterUtility.iso8601Formatter.date(from: "2018-01-21T10:00:00-07:00")!
        }
        
        if let id = event["event_type"] as? Int32, let event_type = self.dataManager.getEventType(id: id) {
            managedEvent.event_type = event_type
        }
        
        if let includes = event["includes"] as? String {
            managedEvent.includes = includes
        } else {
            managedEvent.includes = ""
        }
        
        if let link = event["link"] as? String {
            managedEvent.link = link
        } else {
            managedEvent.link = ""
        }
        
        if let id = event["location"] as? Int32, let location = self.dataManager.getLocation(id: id) {
            managedEvent.location = location
        }
        
        if let startDateString = event["start_date"] as? String, let startDate =  DateFormatterUtility.iso8601Formatter.date(from: startDateString) {
            //print("startdate: \(String(describing:startDateString))")
            managedEvent.start_date = startDate
        } else {
            managedEvent.start_date = DateFormatterUtility.iso8601Formatter.date(from: "2018-01-19T10:00:00-07:00")!
        }
        
        if var title = event["title"] as? String {
            
            if title.localizedCaseInsensitiveContains("Apple") {
                title = title.replacingOccurrences(of: "Apple", with: "[COMPANY X]")
                title = title.replacingOccurrences(of: "apple", with: "[COMPANY X]")
            }
            
            if title.localizedCaseInsensitiveContains("jailbreak") {
                title = title.replacingOccurrences(of: "jailbreak", with: "[CENSORED]")
                title = title.replacingOccurrences(of: "Jailbreak", with: "[CENSORED]")
            }
            
            if title.localizedCaseInsensitiveContains("jail break") {
                title = title.replacingOccurrences(of: "jail break", with: "[CENSORED]")
                title = title.replacingOccurrences(of: "Jail Break", with: "[CENSORED]")
            }
            
            if title.localizedCaseInsensitiveContains("macOS") {
                title = title.replacingOccurrences(of: "macOS", with: "[DESKTOP OS]")
            }
            
            if title.localizedCaseInsensitiveContains("OSX") {
                title = title.replacingOccurrences(of: "OSX", with: "[DESKTOP OS]")
            }
            
            if title.localizedCaseInsensitiveContains("OS X") {
                title = title.replacingOccurrences(of: "OS X", with: "[DESKTOP OS]")
            }
            
            if title.localizedCaseInsensitiveContains("iOS") {
                title = title.replacingOccurrences(of: "iOS", with: "[MOBILE OS]")
            }
            
            managedEvent.title = title
        } else {
            managedEvent.title = "TBD"
        }
        
        if let speakers = event["speakers"] as? [Int32] {
            for speaker_id in speakers {
                if let s = self.dataManager.getSpeaker(speakerId: speaker_id) {
                    managedEvent.addToSpeakers(s)
                }
            }

        }
        
        if let lastUpdateString = event["updated_at"] as? String, let updated_at =  DateFormatterUtility.iso8601Formatter.date(from: lastUpdateString) {
            managedEvent.updated_at = updated_at
        } else {
            managedEvent.updated_at = Date()
        }
                
        try managedContext.save()
        
        return managedEvent
    }
    
    public func resetDB() throws {
        let entities = ["Conference",
                        "Speaker",
                        "Event",
                        "EventType",
                        "EventSpeaker",
                        "Location",
                        "Article",
                        "FAQ",
                        "Notification" ]
        
        for e in entities {
            let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: e)
            let ret = try managedContext.fetch(fr)
            for i in ret {
                managedContext.delete(i as! NSManagedObject)
            }
        }
    }
    public func importConferences(conData : Data) throws -> [String] {
        let _conferences = try JSONSerialization.jsonObject(with: conData, options: .allowFragments) as? [String : Any]
        var updated : [String] = []
        
        guard let conferences = _conferences, let _ = conferences["updated_at"] as? String, let conferenceList = conferences["conferences"] as? [[String : Any]] else
        {
            return [] ;
        }
        
        for con in conferenceList
        {
            if let _ = con["id"] as? Int32,
                let _ = con["updated_at"] as? String
            {
                do {
                    let conUpdated = try importConference(conference: con)
                    updated.append(contentsOf: conUpdated)
                } catch let error {
                    print("Failed to import conference \(con) error \(error)")
                }
            }
        }
        return updated
    }
    
    public func importData(data: Data) throws {
        let _json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
        
        if let json = _json, let list = json["articles"] as? [[String: Any]] {
            print("import articles")
            try importArticles(items: list)
        } else if let json = _json, let list = json["event_types"] as? [[String: Any]] {
            print("import event types")
            try importEventTypes(items: list)
        } else if let json = _json, let list = json["schedule"] as? [[String: Any]] {
            print("import events")
            try importEvents(items: list)
        } else if let json = _json, let list = json["locations"] as? [[String: Any]] {
            print("import locations")
            try importLocations(items: list)
        } else if let json = _json, let list = json["notifications"] as? [[String: Any]] {
            print("import notifications")
            try importNotifications(items: list)
        } else if let json = _json, let list = json["speakers"] as? [[String: Any]] {
            print("import speakers")
            try importSpeakers(items: list)
        } else if let json = _json, let list = json["faqs"] as? [[String: Any]] {
            print("import faqs")
            try importFAQs(items: list)
        } else if let json = _json, let list = json["vendors"] as? [[String: Any]] {
            print("import vendors")
            try importVendors(items: list)
        } else {
            print("import failed")
        }


    }
    
    public func importConference(conference: [String: Any]) throws -> [String] {
        guard let id = conference["id"] as? Int32 else {
            throw ImportError.idDoesntExist
        }
        
        var updated : [String] = []
        
        print("import conference \(id)")
        
        let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Conference")
        fr.predicate = NSPredicate(format: "id = %@", argumentArray: [id])
        
        let ret = try managedContext.fetch(fr)
        
        let managedConference : Conference
        var isNew: Bool = false
        
        if let existing = ret.first as? Conference {
            managedConference = existing
        } else {
            print("Adding new conference to DB")
            managedConference = NSEntityDescription.insertNewObject(forEntityName: "Conference", into: managedContext) as! Conference
            managedConference.id = id
            managedConference.selected = false
            managedConference.updated_at = Calendar.current.date(byAdding: .month, value: -12, to: Date())!
            isNew = true
        }
        let upStr = conference["updated_at"] as! String
        print("Con updated_at string: \(upStr)")
        let updatedAt =  DateFormatterUtility.iso8601Formatter.date(from: upStr)!
        
        if updatedAt > managedConference.updated_at! {
            managedConference.updated_at = updatedAt
            
            if let code = conference["code"] as? String {
                managedConference.code = code
            } else {
                managedConference.code = ""
            }
            
            if let desc = conference["description"] as? String {
                managedConference.desc = desc
            } else {
                managedConference.desc = ""
            }
            
            if let end_date_string = conference["end_date"] as? String, let end_date =  DateFormatterUtility.iso8601Formatter.date(from: end_date_string) {
                managedConference.end_date = end_date
            } else {
                managedConference.end_date = Date()
            }
            
            if let link = conference["link"] as? String {
                managedConference.link = link
            } else {
                managedConference.link = ""
            }
            
            if let name = conference["name"] as? String {
                managedConference.name = name
            } else {
                managedConference.name = ""
            }
            
            if let date_string = conference["start_date"] as? String, let start_date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                managedConference.start_date = start_date
            } else {
                managedConference.start_date = Date()
            }
            
            if let timezone = conference["timezone"] as? String {
                managedConference.timezone = timezone
            } else {
                managedConference.timezone = ""
            }
            
            if isNew {
                if let articles = conference["articles"] as? [String: Any] {
                    //updateArticles(managedConference: managedConference, data: articles)
                    if let date_string = articles["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                        managedConference.articles_updated_at = date
                    }
                    if let link = articles["link"] as? String {
                        managedConference.articles_link = link
                    }
                }
                if let event_types = conference["event_types"] as? [String: Any] {
                    //updateEventTypes(managedConference: managedConference, data: event_types)
                    if let date_string = event_types["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                        managedConference.event_types_updated_at = date
                    }
                    if let link = event_types["link"] as? String {
                        managedConference.event_types_link = link
                    }
                }
                if let faqs = conference["faqs"] as? [String: Any] {
                    //updateFAQs(managedConference: managedConference, data: faqs)
                    if let date_string = faqs["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                        managedConference.faqs_updated_at = date
                    }
                    if let link = faqs["link"] as? String {
                        managedConference.faqs_link = link
                    }
                }
                if let locations = conference["locations"] as? [String: Any] {
                    //updateLocations(managedConference: managedConference, data: locations)
                    if let date_string = locations["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                        managedConference.locations_updated_at = date
                    }
                    if let link = locations["link"] as? String {
                        managedConference.locations_link = link
                    }
                }
                if let notifications = conference["notifications"] as? [String: Any] {
                    //pdateNotifications(managedConference: managedConference, data: notifications)
                    if let date_string = notifications["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                        managedConference.notifications_updated_at = date
                    }
                    if let link = notifications["link"] as? String {
                        managedConference.notifications_link = link
                    }
                }
                if let speakers = conference["speakers"] as? [String: Any] {
                    //updateSpeakers(managedConference: managedConference, data: speakers)
                    if let date_string = speakers["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                        managedConference.speakers_updated_at = date
                    }
                    if let link = speakers["link"] as? String {
                        managedConference.speakers_link = link
                    }
                }
                if let vendors = conference["vendors"] as? [String: Any] {
                    //updateVendors(managedConference: managedConference, data: vendors)
                    if let date_string = vendors["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                        managedConference.vendors_updated_at = date
                    }
                    if let link = vendors["link"] as? String {
                        managedConference.vendors_link = link
                    }
                }
                if let events = conference["events"] as? [String: Any] {
                    //updateEvents(managedConference: managedConference, data: events)
                    if let date_string = events["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                        managedConference.events_updated_at = date
                    }
                    if let link = events["link"] as? String {
                        managedConference.events_link = link
                    }
                }
            }
            
        } else {
            print("conference \(managedConference.name!) details haven't changed")
        }
        
        // Check to see if any of the conference items have changed
        if let item = conference["articles"] as? [String: Any] {
            if let date_string = item["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                if managedConference.articles_updated_at! < date {
                    if let link = item["link"] as? String {
                        managedConference.articles_updated_at = date
                        managedConference.articles_link = link
                        updated.append(link)
                    }
                }
            }
        }
        
        if let item = conference["event_types"] as? [String: Any] {
            if let date_string = item["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                if managedConference.event_types_updated_at! < date {
                    if let link = item["link"] as? String {
                        managedConference.event_types_updated_at = date
                        managedConference.event_types_link = link
                        updated.append(link)
                    }
                }
            }
        }

        if let item = conference["faqs"] as? [String: Any] {
            if let date_string = item["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                if managedConference.faqs_updated_at! < date {
                    if let link = item["link"] as? String {
                        managedConference.faqs_updated_at = date
                        managedConference.faqs_link = link
                        updated.append(link)
                    }
                }
            }
        }
        
        if let item = conference["locations"] as? [String: Any] {
            if let date_string = item["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                if managedConference.locations_updated_at! < date {
                    if let link = item["link"] as? String {
                        managedConference.locations_updated_at = date
                        managedConference.locations_link = link
                        updated.append(link)
                    }
                }
            }
        }
        
        if let item = conference["notifications"] as? [String: Any] {
            if let date_string = item["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                if managedConference.notifications_updated_at! < date {
                    if let link = item["link"] as? String {
                        managedConference.notifications_updated_at = date
                        managedConference.notifications_link = link
                        updated.append(link)
                    }
                }
            }
        }
        
        if let item = conference["speakers"] as? [String: Any] {
            if let date_string = item["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                if managedConference.speakers_updated_at! < date {
                    if let link = item["link"] as? String {
                        managedConference.speakers_updated_at = date
                        managedConference.speakers_link = link
                        updated.append(link)
                    }
                }
            }
        }
        
        if let item = conference["vendors"] as? [String: Any] {
            if let date_string = item["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                if managedConference.vendors_updated_at! < date {
                    if let link = item["link"] as? String {
                        managedConference.vendors_updated_at = date
                        managedConference.vendors_link = link
                        updated.append(link)
                    }
                }
            }
        }
        
        if let item = conference["events"] as? [String: Any] {
            if let date_string = item["updated_at"] as? String, let date =  DateFormatterUtility.iso8601Formatter.date(from: date_string) {
                if managedConference.events_updated_at! < date {
                    if let link = item["link"] as? String {
                        managedConference.events_updated_at = date
                        managedConference.events_link = link
                        updated.append(link)
                    }
                }
            }
        }
        
        try managedContext.save()
        
        return updated
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
    
    
}
