//
//  SettingsView.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 6/21/21.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("passedEvents") var passedEvents: Bool = true
    @AppStorage("displayedConfs") var displayedConfs: Double = 5.0

    var body: some View {
        VStack {
            Spacer()
            Toggle("Show Passed Conferences", isOn: $passedEvents)
            Spacer()
            Slider(value: $displayedConfs, in: 1 ... 25).disabled(!passedEvents)
            Text("Display \(Int(displayedConfs)) Passed Conferences").font(.caption2)
        }

        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
