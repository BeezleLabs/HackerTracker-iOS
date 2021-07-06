//
//  EventController.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 6/18/21.
//

import Combine
import Foundation

class EventController: ObservableObject {
    @Published var events = [EventDocument]()

    var pageToken: String?
    var eventIndex = Date()
    private var conference: String

    private var searchCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }

    deinit {
        searchCancellable?.cancel()
    }

    init(conference: String) {
        self.conference = conference
        fetchEvents(pageSize: 5)
    }

    private func fetchEvents(pageSize:Int = 20) {
        guard let url =
            URL(string: "https://firestore.googleapis.com/v1/projects/hackertest-5a202/databases/(default)/documents/conferences/\(conference)/events?pageSize=\(pageSize)&pageToken=\(pageToken ?? "")&orderBy=begin_timestamp") else { return }
        searchCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Events.self, decoder: decoder())
            .replaceError(with: Events(nextPageToken: nil, documents: [EventDocument]()))
            .receive(on: RunLoop.main)
            .sink(receiveValue: { event in
                self.events.append(contentsOf: event.documents)
                self.pageToken = event.nextPageToken
            })
    }

    func pagination() {
        if pageToken != nil, !events.isEmpty {
            fetchEvents()
        }
    }

    func eventGroup() -> [Date: [EventDocument]] {
        let eventDict = Dictionary(grouping: events, by: { $0.fields.beginTimestamp.timestampValue })
        updateIndex(eventDict: eventDict)
        return eventDict
    }

    private func updateIndex(eventDict: [Date: [EventDocument]]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let someDateTime = formatter.date(from: "2020/08/07 10:31")

        eventIndex = eventDict.sorted {
            $0.key < $1.key
        }.first(where: { key, _ in key > someDateTime! })?.key ?? Array(eventDict.keys).last ?? Date()
    }

    private func stringToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM dd"
        return dateFormatter.date(from: dateString) ?? Date()
    }
}
