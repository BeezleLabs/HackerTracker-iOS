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
import UserNotifications

func getContext() -> NSManagedObjectContext {
    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    return delegate.managedObjectContext!
    
}

func getBackgroundContext() -> NSManagedObjectContext {
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.backgroundManagedObjectContext!
}

func scheduleNotification(at date: Date,_ event:Event) {
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents(in: .current, from: date)
    let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
    
    let content = UNMutableNotificationContent()
    content.title = "Upcoming Event"
    content.body = "\(String(describing: event.title)) in \(String(describing: event.location?.name!))"
    content.sound = UNNotificationSound.default()
    
    let request = UNNotificationRequest(identifier: "hackertracker-\(event.id)", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) {(error) in
        if let error = error {
            NSLog("Error: \(error)")
        }
    }
}

func removeNotification(_ event:Event) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["hackertracker-\(event.id)"])
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
