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
    
    static private(set) var shared : AnonymousSession!
    static private var conferencesToken : UpdateToken?

    var currentConference : ConferenceModel!

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
                    shared.user = authResult
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
    
}
