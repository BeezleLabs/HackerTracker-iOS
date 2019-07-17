//
//  AnonymousSession.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/8/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Foundation
import Firebase

class AnonymousSession {
    
    public typealias FavoritesUpdater = (Result<[Bookmark], Error>) -> ()

    struct WeakContainer<T : AnyObject> {
        weak var content : T?
    }
    
    static private(set) var shared : AnonymousSession!
    static private var conferencesToken : UpdateToken?
    private var bookmarksToken : UpdateToken?
    private var bookmarks : [Bookmark]?

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
