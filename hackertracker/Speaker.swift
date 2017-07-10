//
//  Speaker.swift
//  hackertracker
//
//  Created by Seth Law on 7/8/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import Foundation
import CoreData

class Speaker: NSManagedObject {
    
    @NSManaged var indexsp: Int32
    @NSManaged var last_update: Date
    @NSManaged var who: String
    @NSManaged var sptitle: String
    @NSManaged var media: String
    @NSManaged var bio: String
    
}
