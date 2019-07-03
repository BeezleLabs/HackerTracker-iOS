//
//  FSConferenceDataController.swift
//  hackertracker
//
//  Created by Christopher Mays on 6/19/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Foundation

import Firebase

class UpdateToken<T : Document> {
    fileprivate let collectionValue : Collection<T>;
    fileprivate init (_ collection : Collection<T>) {
        collectionValue = collection;
    }
    
    deinit {
        collectionValue.stopListening()
    }
}

class FSConferenceDataController {
    static let shared = FSConferenceDataController()
    var db: Firestore
    let conferenceQuery : Query?
    
    init() {
        FirebaseApp.configure()
        db = Firestore.firestore()
        conferenceQuery = db.collection("conferences")
    }
    
    func requestConferences(updateHandler: @escaping (Result<[ConferenceModel], Error>) -> Void) -> UpdateToken<ConferenceModel> {
        let query = db.collection("conferences")
        let conferences = Collection<ConferenceModel>(query: query)
        conferences.listen() { (changes) in
            updateHandler(Result<[ConferenceModel], Error>.success(conferences.items))
        }
        return UpdateToken<ConferenceModel>(conferences);
    }
    
    func requestConferenceByCode(forCode conCode: String, updateHandler: @escaping (Result<ConferenceModel, Error>) -> Void) -> UpdateToken<ConferenceModel> {
        let query = db.collection("conferences").whereField("code", isEqualTo: conCode)
        let conferences = Collection<ConferenceModel>(query: query)
        conferences.listen() { (changes) in
            updateHandler(Result<ConferenceModel, Error>.success(conferences.items.first!))
        }
        return UpdateToken<ConferenceModel>(conferences);
    }
    
    func requestEvents(forConference conference: ConferenceModel, updateHandler: @escaping (Result<[HTEventModel], Error>) -> Void) -> UpdateToken<HTEventModel> {
        let query = document(forConference: conference).collection("events")
        let events = Collection<HTEventModel>(query: query)
        events.listen() { (changes) in
            updateHandler(Result<[HTEventModel], Error>.success(events.items))
        }
        return UpdateToken<HTEventModel>(events);
    }
    
    func requestLocations(forConference conference: ConferenceModel, updateHandler: @escaping (Result<[HTLocationModel], Error>) -> Void) -> UpdateToken<HTLocationModel> {
        let query = document(forConference: conference).collection("locations")
        let events = Collection<HTLocationModel>(query: query)
        events.listen() { (changes) in
            updateHandler(Result<[HTLocationModel], Error>.success(events.items))
        }
        return UpdateToken<HTLocationModel>(events);
    }
    
    func requestSpeakers(forConference conference: ConferenceModel, updateHandler: @escaping (Result<[HTSpeaker], Error>) -> Void) -> UpdateToken<HTSpeaker> {
        let query = document(forConference: conference).collection("speakers")
        let events = Collection<HTSpeaker>(query: query)
        events.listen() { (changes) in
            updateHandler(Result<[HTSpeaker], Error>.success(events.items))
        }
        return UpdateToken<HTSpeaker>(events);
    }
    
    private func document(forConference conference: ConferenceModel) -> DocumentReference {
        return db.collection("conferences").document(conference.code);
    }
}
