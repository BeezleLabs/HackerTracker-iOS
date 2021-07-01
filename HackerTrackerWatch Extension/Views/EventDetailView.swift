//
//  EventDetailView.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 6/20/21.
//

import SwiftUI

struct EventDetailView: View {
    let event: EventDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(event.fields.title.stringValue).font(.headline)
                    Spacer()
                    if let speaker = speakerText(speaker: event.fields.speakers) {
                        Text(speaker).font(.caption)
                        Spacer()
                    }
                }
                if let location = event.fields.location.mapValue.fields.hotel?.stringValue {
                    if !location.isEmpty {

                        Text(location).font(.footnote.italic())
                    }
                }
                Text(event.fields.type.mapValue.fields.name.stringValue)
                    .font(.caption2)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color(UIColor(hex: event.fields.type.mapValue.fields.color.stringValue) ?? .purple)))
                    .padding()

                Text(eventDetailsDateDisplay(startDate: event.fields.beginTimestamp.timestampValue, endDate: event.fields.endTimestamp.timestampValue)).font(.footnote.bold()).multilineTextAlignment(.center)
                Spacer()
                Text(event.fields.description.stringValue).font(.caption2)
            }
            .navigationTitle(event.fields.title.stringValue)
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(conference: "DERBYCON9")
    }
}
