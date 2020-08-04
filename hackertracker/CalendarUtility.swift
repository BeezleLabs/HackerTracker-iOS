//
//  CalendarUtility.swift
//  hackertracker
//
//  Created by caleb on 8/1/20.
//  Copyright © 2020 Beezle Labs. All rights reserved.
//

import EventKit
import Foundation
import UIKit

struct CalendarUtility {
    let eventStore = EKEventStore()

    let status: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)

    func requestAuthorization() {
        eventStore.requestAccess(to: EKEntityType.event) { _, error in
            if let error = error {
                print("Request authorization error: \(error.localizedDescription)")
            }
        }
    }

    func requestAuthorizationAndSave(htEvent: HTEventModel, view: HTEventDetailViewController) {
        eventStore.requestAccess(to: EKEntityType.event) { authorized, error in
            if authorized {
                DispatchQueue.main.async {
                    self.addEventToCalendar(htEvent: htEvent, view: view)
                }
            }
            if let error = error {
                print("Request authorization error: \(error.localizedDescription)")
            }
        }
    }

    func addEvent(htEvent: HTEventModel, view: HTEventDetailViewController) {
        switch status {
        case .notDetermined:
            requestAuthorizationAndSave(htEvent: htEvent, view: view)
        case .authorized:
            addEventToCalendar(htEvent: htEvent, view: view)
        case .restricted, .denied:
            deniedAccessAlert(view: view)
        @unknown default:
            break
        }
    }

    private func addEventToCalendar(htEvent: HTEventModel, view: HTEventDetailViewController) {
        let event = createEvent(htEvent: htEvent)
        if !isDuplicate(newEvent: event) {
            saveAlert(htEvent: htEvent, event: event, view: view)
        } else {
            duplicateAlert(htEvent: htEvent, view: view)
        }
    }

    private func createEvent(htEvent: HTEventModel) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        var notes = htEvent.description
        let speakers = htEvent.speakers.map { $0.name }
        if !speakers.isEmpty {
            if speakers.count > 1 {
                notes = "Speakers: \(speakers.joined(separator: ", "))\n\n\(htEvent.description)"
            } else {
                notes = "Speaker: \(speakers.first ?? "")\n\n\(htEvent.description)"
            }
        }

        event.calendar = eventStore.defaultCalendarForNewEvents
        event.startDate = htEvent.begin
        event.endDate = htEvent.end
        event.title = htEvent.title
        event.location = htEvent.location.name
        event.notes = notes
        if let eventUrl = URL(string: htEvent.links) {
            event.url = eventUrl
        }

        return event
    }

    private func saveAlert(htEvent: HTEventModel, event: EKEvent, view: HTEventDetailViewController) {
        let saveAlert = UIAlertController(
            title: "Add \(htEvent.conferenceName) event to calendar",
            message: htEvent.title, preferredStyle: .alert
        )
        saveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        saveAlert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            try? self.eventStore.save(event, span: .thisEvent)
        })

        view.present(saveAlert, animated: true, completion: nil)
    }

    private func deniedAccessAlert(view: HTEventDetailViewController) {
        let deniedAlert = UIAlertController(
            title: "Calendar access is currently disabled for HackerTracker",
            message: "Select OK to view application settings", preferredStyle: .alert
        )
        deniedAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        deniedAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) { if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            }
        })

        view.present(deniedAlert, animated: true, completion: nil)
    }

    private func duplicateAlert(htEvent: HTEventModel, view: HTEventDetailViewController) {
        let duplicateAlert = UIAlertController(
            title: "Duplicate \(htEvent.conferenceName) event found in your calendar",
            message: htEvent.title, preferredStyle: .alert
        )

        duplicateAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        view.present(duplicateAlert, animated: true, completion: nil)
    }

    private func isDuplicate(newEvent: EKEvent) -> Bool {
        let predicate = eventStore
            .predicateForEvents(withStart: newEvent.startDate, end: newEvent.endDate, calendars: nil)
        let currentEvents = eventStore.events(matching: predicate)
        let duplicateEvent = currentEvents
            .contains(where: { $0.title == newEvent.title
                    && $0.startDate == newEvent.startDate
                    && $0.endDate == newEvent.endDate
            })
        return duplicateEvent
    }
}
