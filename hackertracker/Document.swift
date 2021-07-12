//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Firebase

protocol Document {
    init?(dictionary: [String: Any])
}

final class Collection<T: Document> {
    private(set) var items: [T]
    private(set) var documents: [DocumentSnapshot] = []

    let query: Query

    private var listener: ListenerRegistration? {
        didSet {
            oldValue?.remove()
        }
    }

    var count: Int {
        return self.items.count
    }

    subscript(index: Int) -> T {
        return self.items[index]
    }

    init(query: Query) {
        self.items = []
        self.query = query
    }

    func index(of document: DocumentSnapshot) -> Int? {
        return documents.firstIndex(where: { $0.documentID == document.documentID })
    }

    func listen(updateHandler: @escaping ([DocumentChange]) -> Void) {
        guard listener == nil else { return }
        listener = query.addSnapshotListener { [unowned self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshot results: \(String(describing: error))")
                return
            }
            let models = snapshot.documents.map { document -> T in
                if let model = T(dictionary: document.data()) {
                    return model
                } else {
                    // handle error
                    fatalError("Unable to initialize type \(T.self) with dictionary \(document.data())")
                }
            }
            self.items = models
            self.documents = snapshot.documents
            updateHandler(snapshot.documentChanges)
        }
    }

    func stopListening() {
        listener = nil
    }

    deinit {
        stopListening()
    }
}
