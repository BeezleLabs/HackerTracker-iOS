//
//  ScheduleHelper.swift
//  hackertracker
//
//  Created by Seth Law on 6/11/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import CoreData
import Foundation
import UIKit
import UserNotifications

func getContext() -> NSManagedObjectContext {
    let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    return delegate.managedObjectContext!
}

func scheduleNotification(at date: Date, _ event: HTEventModel) {
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents(in: .current, from: date)
    let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)

    let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)

    let content = UNMutableNotificationContent()
    content.title = "Upcoming Event"
    content.body = "\(event.title) in \(String(describing: event.location.name))"
    content.sound = UNNotificationSound.default

    let request = UNNotificationRequest(identifier: "hackertracker-\(event.id)", content: content, trigger: trigger)

    NotificationUtility.addNotification(request: request)
}

func removeNotification(_ event: HTEventModel) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["hackertracker-\(event.id)"])
}

func addBookmark(bookmark: Bookmark?, event: HTEventModel, eventCell: EventCell? = nil) {
    if let bookmark = bookmark {
        // NSLog("Bookmark: \(bookmark.id) \(bookmark.value) to \(!bookmark.value)")
        if bookmark.value {
            removeNotification(event)
        } else {
            scheduleNotification(at: event.begin, event)
        }

        FSConferenceDataController.shared.setFavorite(forConference: AnonymousSession.shared.currentConference, eventModel: event, isFavorite: !bookmark.value, session: AnonymousSession.shared) { _ in
            if let eventCell = eventCell {
                eventCell.eventCellDelegate?.updatedEvents()
            }
        }
    }
}
