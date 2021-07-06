//
//  ConferencesView.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 10/28/20.
//

import SwiftUI
import UIKit

struct ConferencesView: View {
    @AppStorage("passedEvents") var passedEvents: Bool = true
    @AppStorage("displayedConfs") var displayedConfs: Double = 5.0

    @ObservedObject var conferencesController = ConferencesController()
    @State private var selection: String?

    var theme = Theme()

    public var body: some View {
        VStack {
            List {
                ConferenceList(conferences: conferencesController.conferences.current())

                if passedEvents {
                    ConferenceList(conferences: conferencesController.conferences.passed(size: Int(displayedConfs)))
                }

                NavigationLink(destination: SettingsView(), tag: "Settings", selection: $selection) { Button(action: {}) {
                    HStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "gearshape")
                        Text("Settings")
                        Spacer()
                    }}.font(.title3.bold())

                }.listRowBackground(
                    LinearGradient(gradient: Gradient(colors: theme.colors), startPoint: .leading, endPoint: .trailing))

            }.listStyle(CarouselListStyle())
        }

        .navigationTitle("hackertracker")
    }
}

struct ConferencesView_Previews: PreviewProvider {
    static var previews: some View {
        ConferencesView()
    }
}

struct ConferenceList: View {
    @State var theme = Theme()
    var conferences: [CollectionDocument]
    var body: some View {
        ForEach(conferences, id: \.name) { conference in
            NavigationLink(destination: EventView(conference: conference.fields.code.stringValue)) {
                VStack(alignment: .center) {
                    Text(conference.fields.name.stringValue).font(Font.custom(theme.font.bold, size: 16))
                        .multilineTextAlignment(.center)
                    Text(conferenceDatesDisplay(
                        startDate: conference.fields.startTimestamp.timestampValue, endDate: conference.fields.endTimestamp.timestampValue
                    )).font(.caption)
                }.foregroundColor(.black)
            }.listRowBackground(theme.carousel().cornerRadius(5))
        }
    }
}
