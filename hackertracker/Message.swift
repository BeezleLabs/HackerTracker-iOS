//
//  Message.swift
//  hackertracker
//
//  Created by Seth Law on 4/9/15.
//  Copyright (c) 2015 Beezle Labs. All rights reserved.
//

import Foundation
import CoreData

class Message: NSManagedObject {

    @NSManaged var date: Date
    @NSManaged var msg: String
    @NSManaged var id: String

}
