//
//  ConferenceModel.swift
//  hackertracker
//
//  Created by Christopher Mays on 6/18/19.
//  Copyright © 2019 Beezle Labs. All rights reserved.
//

import Foundation

struct ConferenceModel {
    var id : Int
    var name : String
    var code : String
    var endDate : String
    var startDate : String
    var maps : [HTMapModel]
}

extension ConferenceModel : Document {
    init?(dictionary: [String : Any]) {
        let id = dictionary["id"] as? Int ?? 0
        let name = dictionary["name"] as? String ?? ""
        let code = dictionary["code"] as? String ?? ""
        let endDate = dictionary["end_date"] as? String ?? ""
        let startDate = dictionary["start_date"] as? String ?? ""
        var maps : [HTMapModel] = []
        
        if let mapValues = dictionary["maps"] as? Array<Any>  {
            maps = mapValues.compactMap { (element) -> HTMapModel? in
                if let element = element as? Dictionary<String, Any>, let map = HTMapModel(dictionary: element) {
                    return map
                }
                
                return nil
            }
        }
        
        self.init(id: id, name: name, code: code, endDate: endDate, startDate: startDate, maps: maps)
    }
}

struct HTMapModel {
    var file : String
    var name : String
}

extension HTMapModel : Document {
    init?(dictionary: [String : Any]) {
        let name = dictionary["name"] as? String ?? ""
        let file = dictionary["file"] as? String ?? ""
        
        self.init(file: file, name: name)
    }
}
