//
//  AnonymousSession.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/8/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class AnonymousSession {
    
    public typealias FavoritesUpdater = (Result<[Bookmark], Error>) -> ()

    struct WeakContainer<T : AnyObject> {
        weak var content : T?
    }
    
    static private(set) var shared : AnonymousSession!
    static private var conferencesToken : UpdateToken?
    private var eventsToken: UpdateToken?
    private var bookmarksToken : UpdateToken?
    private var bookmarks : [Bookmark]?
    var events : [UserEventModel] = []

    var currentConference : ConferenceModel! {
        didSet {
            setupConference()
        }
    }
    
    var currentFavoritesUpdates : [WeakContainer<UpdateToken>] = []

    var user : User?
    
    static func initialize(conCode: String, completion: @escaping (AnonymousSession?) -> Void) {
        Auth.auth().signInAnonymously() { (authResult, error) in
            if let _ = error {
                completion(nil)
                return
            }
            
            self.conferencesToken = FSConferenceDataController.shared.requestConferenceByCode(forCode: conCode) { (result) in
                switch result {
                case .success(let con):
                    shared = AnonymousSession(conference:con)
                    shared.user = authResult?.user
                    shared.setupConference()
                    completion(shared)
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
    
    public init(conference : ConferenceModel) {
        currentConference = conference
    }
    
    func setupConference() {
        self.currentFavoritesUpdates = []
        self.bookmarksToken = warmFavoritesCache(forConference: currentConference) { (result) in
            switch result {
            case .success(let bookmarks):
                self.bookmarks = bookmarks
            case .failure(_):
                NSLog("failure")
            }
            for weakContainer in self.currentFavoritesUpdates {
                if let updateToken = weakContainer.content, let block = updateToken.collectionValue as? FavoritesUpdater {
                    block(result);
                }
            }
        }
        
        self.eventsToken = FSConferenceDataController.shared.requestEvents(forConference: currentConference, descending: false) { (result) in
            switch result {
            case .success(let eventsList):
                self.events.removeAll()
                self.events.append(contentsOf: eventsList)
            case .failure(let _):
                NSLog("")
            }
        }
        
        let fm = FileManager.default
        let docDir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storageRef = FSConferenceDataController.shared.storage.reference()

        for m in currentConference.maps {
            let path = "\(currentConference.code)/\(m.file)"
            let mRef = storageRef.child(path)
            let mLocal = docDir.appendingPathComponent(path)
            if fm.fileExists(atPath: mLocal.path) {
                // TODO: Add logic to check md5 hash and re-update if it has changed
                //NSLog("Map file (\(path)) already exists")
            } else {
                _ = mRef.write(toFile: mLocal) { url, error in
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
            return nil;
        }
        
        let query = document(forConference: conference).collection("users").document(user.uid).collection("bookmarks")
        let bookmarks = Collection<Bookmark>(query: query)
        bookmarks.listen { (changes) in
            updateHandler(Result<[Bookmark], Error>.success(bookmarks.items))
        }
        
        return UpdateToken(bookmarks);
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
        return Firestore.firestore().collection("conferences").document(conference.code);
    }
}
