//
//  Event.swift
//  hackertracker
//
//  Created by Seth Law on 4/9/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import Foundation
import CoreData

@objc(Event)
class Event: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var start_time: String
    @NSManaged var end_time: String
    @NSManaged var date: NSDate
    @NSManaged var location: String
    @NSManaged var details: String
    @NSManaged var name: String
    @NSManaged var starred: NSNumber

}
