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

    @NSManaged var id: Int32
    @NSManaged var title: String
    @NSManaged var begin: NSDate
    @NSManaged var end: NSDate
    @NSManaged var location: String
    @NSManaged var details: String
    @NSManaged var who: String
    @NSManaged var type: String
    @NSManaged var link: String
    @NSManaged var demo: Bool
    @NSManaged var tool: Bool
    @NSManaged var exploit: Bool
    @NSManaged var starred: Bool

}
