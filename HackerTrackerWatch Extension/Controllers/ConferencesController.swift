//
//  ConferencesController.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 10/28/20.
//

import Combine
import Foundation

class ConferencesController: ObservableObject {
    @Published var conferences = Collection(nextPageToken: nil, documents: [CollectionDocument]())

    private var searchCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }

    deinit {
        searchCancellable?.cancel()
    }

    init(size _: Int = 50) {
        guard let url =
            URL(string: "https://firestore.googleapis.com/v1/projects/hackertest-5a202/databases/(default)/documents/conferences?pageSize=50&orderBy=start_timestamp%20desc") else { return }
        searchCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Collection.self, decoder: decoder())
            .replaceError(with: Collection(nextPageToken: nil, documents: [CollectionDocument]()))
            .receive(on: RunLoop.main)
            .assign(to: \.conferences, on: self)
    }
}

extension Collection {
    func current() -> [CollectionDocument] {
        return documents.filter { $0.fields.endTimestamp.timestampValue > Date() }
    }

    func passed(size: Int) -> [CollectionDocument] {
        return Array(documents.prefix(size).filter { $0.fields.endTimestamp.timestampValue < Date() })
    }
}

struct Conferences {
    let current: [CollectionDocument]
    let passed: [CollectionDocument]
}
