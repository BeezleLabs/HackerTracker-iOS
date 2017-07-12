//
//  ScheduleHelper.swift
//  hackertracker
//
//  Created by Seth Law on 6/11/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

func getContext() -> NSManagedObjectContext {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    return delegate.managedObjectContext!
    
}

func updateSpeakers(_ data: Data) -> Bool {
    
    let context = getContext()
    
    let json = JSON(data: data, options: JSONSerialization.ReadingOptions.mutableLeaves, error: nil)
    
    let isodf = DateFormatterUtility.iso8601pdtFormatter
    let lastsync = lastsyncDate()
    let update_date = isodf.date(from: json["update_date"].stringValue)!
    
    if ( lastsync == nil || (update_date.compare(lastsync!) == ComparisonResult.orderedDescending)) {
    
        let speakers = json["speakers"].array!
    
        for speaker in speakers {
        
            if ( speaker["indexsp"] != JSON.null && speaker["last_update"] != JSON.null ) {
                let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Speaker")
                fre.predicate = NSPredicate(format: "indexsp = %@", argumentArray: [speaker["indexsp"].stringValue])
                let ret = try! context.fetch(fre)
            
                if ret.count > 0 {
                    let s: Speaker = ret[0] as! Speaker
                    if (s.last_update.compare(isodf.date(from: speaker["last_udpate"].stringValue)!) == ComparisonResult.orderedDescending) {
                        if (!updateSpeaker(s,speaker)) {
                            NSLog("Error updating speaker: \(s.who)")
                            return false
                        }
                    }
                } else {
                    if (!addSpeaker(speaker)) {
                        NSLog("Failed to add speaker: \(speaker["who"].stringValue)")
                        return false
                    }
                }
            
            }
        
        }
    }
    
    return true
}

func updateSpeaker(_ s: Speaker,_ speaker: JSON) -> Bool {
    
    if (speaker["who"] != JSON.null) {
        s.who = speaker["who"].stringValue
    } else {
        s.who = "Mystery Speaker"
    }
    
    if (speaker["sptitle"] != JSON.null) {
        s.sptitle = speaker["sptitle"].stringValue
    } else {
        s.sptitle = ""
    }
    
    if (speaker["media"] != JSON.null) {
        s.media = speaker["media"].stringValue
    } else {
        s.media = ""
    }
    
    if (speaker["bio"] != JSON.null) {
        s.bio = speaker["bio"].stringValue
    } else {
        s.bio = ""
    }
    
    if (speaker["last_update"] != JSON.null) {
        s.last_update = DateFormatterUtility.iso8601pdtFormatter.date(from: speaker["last_update"].stringValue)!
    } else {
        s.last_update = Date()
    }
    
    do {
        try getContext().save()
        return true
    } catch let error as NSError {
        NSLog("error: \(error)")
        return false
    }
}

func addSpeaker(_ speaker: JSON) -> Bool {
    
    let s = NSEntityDescription.insertNewObject(forEntityName: "Speaker", into: getContext()) as! Speaker
    if (speaker["indexsp"] != JSON.null) {
        s.indexsp = speaker["indexsp"].int32Value
    }
    
    return updateSpeaker(s, speaker)
    
}

func getSpeaker(_ indexsp: Int32) -> Speaker? {
    
    let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Speaker")
    fre.predicate = NSPredicate(format: "indexsp = %@", argumentArray: [indexsp])
    let ret = try! getContext().fetch(fre)
    
    if (ret.count > 0) {
        return ret[0] as? Speaker
    } else {
        return nil
    }
    
}

func getEvent(_ index: Int32) -> Event? {
    
    let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
    fre.predicate = NSPredicate(format: "index = %@", argumentArray: [index])
    let ret = try! getContext().fetch(fre)
    
    if (ret.count > 0) {
        return ret[0] as? Event
    } else {
        return nil
    }
    
}

func getEventSpeakers(_ index: Int32) -> [Speaker] {
    var speakers: [Speaker] = []
    
    let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EventSpeaker")
    fre.predicate = NSPredicate(format: "index = %@", argumentArray: [index])
    let ret = try! getContext().fetch(fre)
    
    
    for es in ret {
        speakers.append(getSpeaker(((es as! EventSpeaker).indexsp))!)
    }
    
    return speakers
}

func getEventfromSpeaker(_ indexsp: Int32) -> [Event] {
    var events: [Event] = []
    
    let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EventSpeaker")
    fre.predicate = NSPredicate(format: "indexsp = %@", argumentArray: [indexsp])
    let ret = try! getContext().fetch(fre)
    
    
    for es in ret {
        events.append(getEvent(((es as! EventSpeaker).index))!)
    }
    
    return events
}

func lastsyncDate() -> Date? {
    let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
    let ret = try! getContext().fetch(fr)
    
    if (ret.count > 0) {
        return (ret[0] as! Status).lastsync
    }
    return nil
}

func setsyncDate(_ date: Date) -> Bool {
    
    let fr:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Status")
    let ret = try! getContext().fetch(fr)
    
    if (ret.count > 0) {
        (ret[0] as! Status).lastsync = date
    } else {
        let status = NSEntityDescription.insertNewObject(forEntityName: "Status", into: getContext()) as! Status
        status.lastsync = date
    }
    
    do {
        try getContext().save()
        return true
    } catch let error as NSError {
        NSLog("error: \(error)")
        return false
    }
}

func updateSchedule(_ data: Data) -> Bool {
    
    let context = getContext()
    
    let json = JSON(data: data, options: JSONSerialization.ReadingOptions.mutableLeaves, error: nil)
    
    let df = DateFormatterUtility.iso8601pdtFormatter
    
    let lastsync = lastsyncDate()
    
    let update_date = df.date(from: json["update_date"].stringValue)!
    
    var retBool: Bool = true
    
    if ( lastsync == nil || (update_date.compare(lastsync!) == ComparisonResult.orderedDescending)) {
        
        let schedule = json["schedule"].array!
        
        for event in schedule {
            if ( event["index"] != JSON.null && event["updated_at"] != JSON.null ) {
                let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Event")
                fre.predicate = NSPredicate(format: "index = %@", argumentArray: [event["index"].stringValue])
                let ret = try! context.fetch(fre)
                
                if ret.count > 0 {
                    let e: Event = ret[0] as! Event
                    if (e.updated_at.compare(df.date(from: event["updated_at"].stringValue)!) == ComparisonResult.orderedDescending) {
                        // Start here
                        if (!updateEvent(e,event)) {
                            NSLog("Error updating event: \(e.id)")
                            retBool = false
                        }
                    }
                } else {
                    if (!addEvent(event)) {
                        NSLog("Failed to add event: \(event["id"].stringValue)")
                        retBool = false
                    }
                }
                
            }
        }
        
        _ = setsyncDate(update_date)
        
        let message2 = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message2.date = update_date
        message2.msg = "Schedule updated with \(schedule.count) events."
        NSLog(message2.msg)
        
        do {
            try context.save()
        } catch let error as NSError {
            NSLog("error: \(error)")
            retBool = false
        }

    } else {
        NSLog("Schedule is up to date")
    }
    
    return retBool
}

func addEventSpeaker(_ index: Int32, _ indexsp: Int32) -> Bool {
    
    let fre:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EventSpeaker")
    fre.predicate = NSPredicate(format: "index = %@ AND indexsp = %@", argumentArray: [index,indexsp])
    let ret = try! getContext().fetch(fre)
    
    if (ret.count < 1) {
        let es = NSEntityDescription.insertNewObject(forEntityName: "EventSpeaker", into: getContext()) as! EventSpeaker
        es.index = index
        es.indexsp = indexsp
    }
    
    do {
        try getContext().save()
        return true
    } catch let error as NSError {
        NSLog("error: \(error)")
        return false
    }
    
}

func updateEvent(_ e: Event,_ event: JSON) -> Bool {
    
    if (event["who"] != JSON.null) {
        for es in event["who"].array! {
            _ = addEventSpeaker(e.index,es["indexsp"].int32Value)
        }
    }
    
    if (event["id"] != JSON.null) {
        e.id = event["id"].stringValue
    } else {
        e.id = ""
    }
    
    if (event["includes"] != JSON.null) {
        e.includes = event["includes"].stringValue
    } else {
        e.includes = ""
    }
    
    if (event["title"] != JSON.null) {
        e.title = event["title"].stringValue
    } else {
        e.title = "TBD"
    }
    
    if (event["link"] != JSON.null) {
        e.link = event["link"].stringValue
    } else {
        e.link = ""
    }
    
    if (event["location"] != JSON.null) {
        e.location = event["location"].stringValue
    } else {
        e.location = ""
    }
    
    if (event["entry_type"] != JSON.null) {
        e.entry_type = event["entry_type"].stringValue
    } else {
        e.entry_type = ""
    }
    
    if (event["description"] != JSON.null) {
        e.details = event["description"].stringValue
    } else {
        e.details = ""
    }
    
    if (event["start_date"] != JSON.null) {
        e.start_date = DateFormatterUtility.iso8601pdtFormatter.date(from: event["start_date"].stringValue)!
    } else {
        e.start_date = DateFormatterUtility.iso8601pdtFormatter.date(from: "2017-07-25T10:00:00")!
    }
    
    if (event["end_date"] != JSON.null) {
        e.end_date = DateFormatterUtility.iso8601pdtFormatter.date(from: event["end_date"].stringValue)!
    } else {
        e.end_date = DateFormatterUtility.iso8601pdtFormatter.date(from: "2017-07-25T10:00:00")!
    }
    
    if (event["last_update"] != JSON.null) {
        e.updated_at = DateFormatterUtility.iso8601pdtFormatter.date(from: event["last_update"].stringValue)!
    } else {
        e.updated_at = Date()
    }
    
    if (event["recommended"] != JSON.null) {
        e.recommended = event["recommended"].boolValue
    } else {
        e.recommended = false
    }
    
    do {
        try getContext().save()
        return true
    } catch let error as NSError {
        NSLog("error: \(error)")
        return false
    }
}

func addEvent(_ event: JSON) -> Bool {
    
    let e = NSEntityDescription.insertNewObject(forEntityName: "Event", into: getContext()) as! Event
    if (event["index"] != JSON.null) {
        e.index = event["index"].int32Value
        e.starred = false
    }
    
    return updateEvent(e, event)
    
}


// Certificate Pinning Delegate

class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                
                if(errSecSuccess == status) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        let file_der = Bundle.main.path(forResource: "cert", ofType: "der")
                        
                        if let file = file_der {
                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
    
}
