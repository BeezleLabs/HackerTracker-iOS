//
//  DateFormatterUtility.swift
//  hackertracker
//
//  Created by Chris Mays on 1/16/17.
//  Copyright © 2017 Beezle Labs. All rights reserved.
//

import Foundation

/**
    This class exists to minimize the number of date formatters that need
    to be created. The creation of NSDateFormatters are very expensive, and it
    is noted by some that changing the dateformat after creation is even more
    expensive than creating a new formatter all together. On top of helping with
    performance this will help keep date formats consistent throughout the app.
    
    Look here for further information:
    http://www.chibicode.org/?p=41
 */
class DateFormatterUtility {
    
    var tz = TimeZone(identifier: "America/Los_Angeles")
    
    /*static let shared : [String:DateFormatterUtility] =
        ["America/Los_Angeles": DateFormatterUtility(identifier: "America/Los_Angeles"),
         "America/Chicago": DateFormatterUtility(identifier: "America/Chicago"),
         "America/Denver": DateFormatterUtility(identifier: "America/Denver"),
         "America/New_York": DateFormatterUtility(identifier: "America/New_York")
    ] */
    
    static let shared = DateFormatterUtility(identifier: "America/Los_Angeles")
    
    init(identifier: String) {
        self.update(identifier: identifier)
    }
    
    func update(identifier: String) {
        tz = TimeZone(identifier: identifier)
        yearMonthDayTimeFormatter.timeZone = tz
        yearMonthDayFormatter.timeZone = tz
        monthDayTimeFormatter.timeZone = tz
        yearMonthDayNoTimeZoneTimeFormatter.timeZone = tz
        dayOfWeekFormatter.timeZone = tz
        shortDayOfMonthFormatter.timeZone = tz
        dayMonthDayOfWeekFormatter.timeZone = tz
        shortDayMonthDayTimeOfWeekFormatter.timeZone = tz
        dayOfWeekTimeFormatter.timeZone = tz
        hourMinuteTimeFormatter.timeZone = tz
    }

    // time format
    let yearMonthDayTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //Year-Month-Day
    let yearMonthDayFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //UTC time format
    let monthDayTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //UTC iso8601 time format
    let iso8601Formatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //Year-Month-Day time format
    let yearMonthDayNoTimeZoneTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-d HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    
    //DOW format
    let dayOfWeekFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    //D format
    let shortDayOfMonthFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E"
        return formatter
    }()
    
    //DOW format
    let dayMonthDayOfWeekFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    //DOW format
    let shortDayMonthDayTimeOfWeekFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EE, MMM d HH:mm"
        return formatter
    }()
    
    //DOW Hour:Minute time format
    let dayOfWeekTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EE HH:mm"
        return formatter
    }()

    //Hour:Minute time format
    let hourMinuteTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

}
