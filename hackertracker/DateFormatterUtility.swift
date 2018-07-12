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

    //UTC time format
    static let yearMonthDayTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //UTC time format
    static let yearMonthDayTimeNoSecondsFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    
    //Yeat-Month-Day
    static let yearMonthDayFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //UTC time format
    static let monthDayTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //UTC iso8601 time format
    static let iso8601Formatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //UTC iso8601 time format
    static let iso8601pdtFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //Year-Month-Day time format
    static let yearMonthDayNoTimeZoneTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.dateFormat = "yyyy-MM-d HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    
    //DOW format
    static let dayOfWeekFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    //DOW format
    static let dayMonthDayOfWeekFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    //DOW Hour:Minute time format
    static let dayOfWeekTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EE HH:mm"
        return formatter
    }()

    //Hour:Minute time format
    static let hourMinuteTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    //Full DOW full Month day hour minute
    static let dayOfWeekMonthTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMMM dd HH:mm"
        return formatter
    }()
    
    //Partial Day of week Ex: Fri
    static let partialDayOfWeekFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PDT")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E"
        return formatter
    }()


}
