//
//  AnonymousSession.swift
//  hackertracker
//
//  Created by Christopher Mays on 7/8/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Foundation

class AnonymousSession {
    
    static private(set) var shared : AnonymousSession!
    static private var conferencesToken : UpdateToken<ConferenceModel>?

    var currentConference : ConferenceModel!

    static func initialize(conCode: String, completion: @escaping (AnonymousSession?) -> Void) {
        conferencesToken = FSConferenceDataController.shared.requestConferenceByCode(forCode: conCode) { (result) in
            switch result {
            case .success(let con):
                shared = AnonymousSession(conference:con)
                completion(shared)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    public init(conference : ConferenceModel) {
        currentConference = conference
    }
    
}
