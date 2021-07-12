//
//  AnonymousSession.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/8/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Firebase
import FirebaseStorage
import Foundation

class AnonymousSession {
    typealias FavoritesUpdater = (Result<[Bookmark], Error>) -> Void

    struct WeakContainer<T: AnyObject> {
        weak var content: T?
    }

    private(set) static var shared: AnonymousSession! // swiftlint:disable:this implicitly_unwrapped_optional
    private static var conferencesToken: UpdateToken?
    private var bookmarksToken: UpdateToken?
    private var bookmarks: [Bookmark]?

    var currentConference: ConferenceModel {
        didSet {
            setupConference()
        }
    }

    var currentFavoritesUpdates: [WeakContainer<UpdateToken>] = []

    var user: User?

    static func initialize(conCode: String, completion: @escaping (AnonymousSession?) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            if error != nil {
                completion(nil)
                return
            }

            self.conferencesToken = FSConferenceDataController.shared.requestConferenceByCode(forCode: conCode) { result in
                switch result {
                case .success(let con):
                    shared = AnonymousSession(conference: con)
                    shared.user = authResult?.user
                    shared.setupConference()
                    completion(shared)
                case .failure:
                    completion(nil)
                }
            }
        }
    }

    init(conference: ConferenceModel) {
        currentConference = conference
    }

    func setupConference() {
        self.currentFavoritesUpdates = []
        self.bookmarksToken = warmFavoritesCache(forConference: currentConference) { result in
            switch result {
            case .success(let bookmarks):
                self.bookmarks = bookmarks
            case .failure:
                NSLog("failure")
            }
            for weakContainer in self.currentFavoritesUpdates {
                if let updateToken = weakContainer.content, let block = updateToken.collectionValue as? FavoritesUpdater {
                    block(result)
                }
            }
        }

        DateFormatterUtility.shared.update(identifier: currentConference.timeZone)

        let fileManager = FileManager.default
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storageRef = FSConferenceDataController.shared.storage.reference()

        for map in currentConference.maps {
            let path = "\(currentConference.code)/\(map.file)"
            let mRef = storageRef.child(path)
            let mLocal = docDir.appendingPathComponent(path)
            if fileManager.fileExists(atPath: mLocal.path) {
                // TODO: Add logic to check md5 hash and re-update if it has changed
                // NSLog("Map file (\(path)) already exists")
            } else {
                _ = mRef.write(toFile: mLocal) { _, error in
                    if let error = error {
                        NSLog("Error \(error) retrieving \(path)")
                    } else {
                        NSLog("Got map \(path)")
                    }
                }
            }
        }
    }

    func warmFavoritesCache(forConference conference: ConferenceModel,
                            updateHandler: @escaping (Result<[Bookmark], Error>) -> Void) -> UpdateToken? {
        guard let user = user else {
            return nil
        }

        let query = document(forConference: conference).collection("users").document(user.uid).collection("bookmarks")
        let bookmarks = Collection<Bookmark>(query: query)
        bookmarks.listen { _ in
            updateHandler(Result<[Bookmark], Error>.success(bookmarks.items))
        }

        return UpdateToken(bookmarks)
    }

    func requestFavorites(updateHandler: @escaping (Result<[Bookmark], Error>) -> Void) -> UpdateToken? {
        if let bookmarks = self.bookmarks {
            updateHandler(Result<[Bookmark], Error>.success(bookmarks))
        }

        let updateToken = UpdateToken(updateHandler)
        currentFavoritesUpdates.append(WeakContainer(content: updateToken))
        return updateToken
    }

    private func document(forConference conference: ConferenceModel) -> DocumentReference {
        return Firestore.firestore().collection("conferences").document(conference.code)
    }
}
