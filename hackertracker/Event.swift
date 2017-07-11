//
//  Event.swift
//  hackertracker
//
//  Created by Seth Law on 4/9/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {

    @NSManaged var index: Int32
    
    @NSManaged var start_date: Date
    @NSManaged var end_date: Date
    @NSManaged var updated_at: Date

    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var location: String
    @NSManaged var details: String
    @NSManaged var entry_type: String
    @NSManaged var link: String
    @NSManaged var includes: String
    
    @NSManaged var recommended: Bool
    @NSManaged var starred: Bool
    
    public func isTool() -> Bool
    {
        return includes.lowercased().contains("tool")
    }
    
    public func isDemo() -> Bool
    {
        return includes.lowercased().contains("demo")
    }
    
    public func isExploit() -> Bool
    {
        return includes.lowercased().contains("exploit")
    }

}
