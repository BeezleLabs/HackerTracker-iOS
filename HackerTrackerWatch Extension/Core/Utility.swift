//
//  Utility.swift
//  HackerTracker-watchOS WatchKit Extension
//
//  Created by caleb on 10/28/20.
//

import Foundation

func decoder() -> JSONDecoder {
    let decode = JSONDecoder()
    decode.dateDecodingStrategy = .iso8601
    return decode
}

func eventDateDisplay(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
}

func dateSection(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, MMM dd HH:mm"
    return dateFormatter.string(from: date)
}

func conferenceDatesDisplay(startDate: Date, endDate: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
}

func eventDetailsDateDisplay(startDate: Date, endDate: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE, MMM dd\nhh:mm"
    let start = dateFormatter.string(from: startDate)
    dateFormatter.dateFormat = "hh:mm z"
    let end = dateFormatter.string(from: endDate)
    return "\(start) - \(end)"
}

func weekdayToStirng(weekday: String) -> String {
    guard let weekdayInt = Int(weekday) else { return weekday }
    let dateFormatter = DateFormatter()
    return dateFormatter.weekdaySymbols[weekdayInt - 1]
}

func speakerText(speaker: Speakers) -> String? {
    return speaker.arrayValue.values?.compactMap { $0.mapValue.fields.name.stringValue }.joined(separator: ", ")
}
