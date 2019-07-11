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
    
    func requestEvents(forConference conference: ConferenceModel, eventId: Int, updateHandler: @escaping (Result<HTEventModel, Error>) -> Void) -> UpdateToken<HTEventModel> {
        let query = document(forConference: conference).collection("events").whereField("id", isEqualTo: eventId)
        let events = Collection<HTEventModel>(query: query)
        events.listen() { (changes) in
            updateHandler(Result<HTEventModel, Error>.success(events.items.first!))
        }
        return UpdateToken<HTEventModel>(events);
    }
    
    func requestSpeaker(forConference conference: ConferenceModel, speakerId: Int, updateHandler: @escaping (Result<HTSpeaker, Error>) -> Void) -> UpdateToken<HTSpeaker> {
        let query = document(forConference: conference).collection("speakers").whereField("id", isEqualTo: speakerId)
        let speakers = Collection<HTSpeaker>(query: query)
        speakers.listen() { (changes) in
            updateHandler(Result<HTSpeaker, Error>.success(speakers.items.first!))
        }
        return UpdateToken<HTSpeaker>(speakers);
    }
    
    func requestSpeakers(forConference conference: ConferenceModel, updateHandler: @escaping (Result<[HTSpeaker], Error>) -> Void) -> UpdateToken<HTSpeaker> {
        let query = document(forConference: conference).collection("speakers").order(by: "name")
        let speakers = Collection<HTSpeaker>(query: query)
        speakers.listen() { (changes) in
            updateHandler(Result<[HTSpeaker], Error>.success(speakers.items))
        }
        return UpdateToken<HTSpeaker>(speakers);
    }
    
    func requestEvents(forConference conference: ConferenceModel,
                       limit: Int? = nil,
                       descending: Bool = false,
                       updateHandler: @escaping (Result<[HTEventModel], Error>) -> Void) -> UpdateToken<HTEventModel> {
        var query: Query?
        query = document(forConference: conference).collection("events").order(by: "begin_timestamp", descending: descending).limit(to: limit ?? Int.max)
        let events = Collection<HTEventModel>(query: query!)
        events.listen() { (changes) in
            updateHandler(Result<[HTEventModel], Error>.success(events.items))
        }
        return UpdateToken<HTEventModel>(events);
    }
    
    func requestEvents(forConference conference: ConferenceModel,
                       startDate: Date,
                       limit: Int? = nil,
                       descending: Bool = false,
                       updateHandler: @escaping (Result<[HTEventModel], Error>) -> Void) -> UpdateToken<HTEventModel> {
        var query: Query?
        query = document(forConference: conference).collection("events").whereField("begin_timestamp", isGreaterThan: startDate).order(by: "begin_timestamp", descending: descending).limit(to: limit ?? Int.max)
        
        let events = Collection<HTEventModel>(query: query!)
        events.listen() { (changes) in
            updateHandler(Result<[HTEventModel], Error>.success(events.items))
        }
        return UpdateToken<HTEventModel>(events);
    }
    
    func requestEvents(forConference conference: ConferenceModel,
                       inDate: Date,
                       limit: Int? = nil,
                       descending: Bool = false,
                       updateHandler: @escaping (Result<[HTEventModel], Error>) -> Void) -> UpdateToken<HTEventModel> {
        var query: Query?
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: inDate)
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        query = document(forConference: conference).collection("events").whereField("begin_timestamp", isGreaterThan: start).whereField("begin_timestamp", isLessThan: end).order(by: "begin_timestamp", descending: descending).limit(to: limit ?? Int.max)
        
        let events = Collection<HTEventModel>(query: query!)
        events.listen() { (changes) in
            updateHandler(Result<[HTEventModel], Error>.success(events.items))
        }
        return UpdateToken<HTEventModel>(events);
    }
    
    func requestEvents(forConference conference: ConferenceModel,
                       endDate: Date,
                       limit: Int? = nil,
                       descending: Bool = false,
                       updateHandler: @escaping (Result<[HTEventModel], Error>) -> Void) -> UpdateToken<HTEventModel> {
        let query = document(forConference: conference).collection("events").whereField("end_timestamp", isLessThan: endDate).order(by: "end_timestamp", descending: descending).limit(to: limit ?? Int.max)
        
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
    
    private func document(forConference conference: ConferenceModel) -> DocumentReference {
        return db.collection("conferences").document(conference.code);
    }
}
