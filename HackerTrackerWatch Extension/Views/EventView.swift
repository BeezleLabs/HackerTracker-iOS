//
//  EventView.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 6/18/21.
//

import SwiftUI

struct EventView: View {
    @ObservedObject var eventController: EventController
    let conference: String
    @State var theme = Theme()

    init(conference: String) {
        self.conference = conference
        eventController = EventController(conference: conference)
    }

    var body: some View {
        ScrollView {
            ScrollViewReader { _ in
                LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                    ForEach(eventController.eventGroup().sorted {
                        $0.key < $1.key
                    }, id: \.key) { weekday, events in
                            EventData(weekday: dateSection(date: weekday), events: events, themeColor: theme.carousel())
                    }

                    if eventController.pageToken != nil {
                        ProgressView()
                            .onAppear {
                                eventController.pagination()
                            }
                    }
                }
            }
        }
        .navigationTitle(conference)
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(conference: "DEFCON28")
    }
}

struct EventData: View {
    let weekday: String
    let events: [EventDocument]
    let themeColor: Color

    var body: some View {
        Section(header: Text(weekday).padding()
            .frame(maxWidth: .infinity)
            .border(themeColor, width: 3)

            .background(Color.black)) {
                ForEach(events, id: \.name) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventCell(event: event)
                    }
                }
        }
    }
}

struct EventCell: View {
    let event: EventDocument
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Rectangle().fill(event.fields.type.swiftuiColor)
                    .frame(width: 5)
                VStack(alignment: .leading) {
                    Text(event.fields.title.stringValue).font(.body)
                    VStack(alignment: .leading) {
                        HStack {
                            Circle().foregroundColor(event.fields.type.swiftuiColor)
                                .frame(width: 8, height: 8, alignment: .center)
                            Text(event.fields.type.mapValue.fields.name.stringValue).font(.caption2)
                        }
                    }.frame(minWidth: 0, maxWidth: .infinity)
                }
            }
        }
    }
}
