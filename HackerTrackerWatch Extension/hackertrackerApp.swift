//
//  hackertrackerApp.swift
//  HackerTrackerWatch Extension
//
//  Created by caleb on 7/1/21.
//  Copyright © 2021 Beezle Labs. All rights reserved.
//

import SwiftUI

@main
struct hackertrackerApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ConferencesView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
