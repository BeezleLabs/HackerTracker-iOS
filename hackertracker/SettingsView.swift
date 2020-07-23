//
//  SettingsView.swift
//  hackertracker
//
//  Created by caleb on 7/22/20.
//  Copyright © 2020 Beezle Labs. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var settings = HTSettings()
    
    var body: some View {
        VStack {
            Toggle(isOn: self.$settings.preferLocalTime) {
                Text("Prefer Local Time").foregroundColor(.white)
            }.padding()
            Spacer()
        }
        .background(Color(UIColor.backgroundGray))
    }
}

class HTSettings: ObservableObject {
    @Published var preferLocalTime: Bool = UserDefaults.standard.bool(forKey: "PreferLocalTime") {
        didSet {
            UserDefaults.standard.set(self.preferLocalTime, forKey: "PreferLocalTime")
            AnonymousSession.shared.currentConference = AnonymousSession.shared.currentConference
        }
    }
}
