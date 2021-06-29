//
//  NotificationUtility.swift
//  hackertracker
//
//  Created by caleb on 7/27/20.
//  Copyright © 2020 Beezle Labs. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationUtility {
    static var status: UNAuthorizationStatus? {
        var authorizationStatus: UNAuthorizationStatus?
        let semasphore = DispatchSemaphore(value: 0)

        DispatchQueue.global().async {
            UNUserNotificationCenter.current().getNotificationSettings { setttings in
                authorizationStatus = setttings.authorizationStatus
                semasphore.signal()
            }
        }

        semasphore.wait()

        return authorizationStatus
    }

    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print("Request authorization error: \(error.localizedDescription)")
            }
        }
    }

    static func addNotification(request: UNNotificationRequest) {
        UNUserNotificationCenter.current().getNotificationSettings { setttings in
            switch setttings.authorizationStatus {
            case .authorized, .provisional:
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        NSLog("Error: \(error)")
                    }
                }
            case .notDetermined:
                NotificationUtility.requestAuthorization()
            case .denied:
                break
            case .ephemeral:
                break
            @unknown default:
                break
            }
        }
    }

    static func checkAndRequestAuthorization() {
        guard let status = NotificationUtility.status else { return }
        switch status {
        case .notDetermined:
            requestAuthorization()
        default:
            break
        }
    }
}
