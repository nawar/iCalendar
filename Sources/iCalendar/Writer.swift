//
//  Writer.swift
//  iCalendar
//
//  Created by Michael Brown on 05/07/2017.
//  Copyright © 2017 iCalendar. All rights reserved.
//

import Foundation

public struct Writer {
    static let dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss"
        return formatter
    }()
    
    static let iCalFoldLength = 73 // see https://tools.ietf.org/html/rfc5545#section-3.1
    static let calendarHeader =
        """
        BEGIN:VCALENDAR\r
        PRODID;X-RICAL-TZSOURCE=TZINFO:-//Michael Brown//iCalendar//EN\r
        CALSCALE:GREGORIAN\r
        VERSION:2.0\r

        """
    static let calendarFooter = "END:VCALENDAR\r\n"
    static let eventHeader = "BEGIN:VEVENT\r\n"
    static let eventFooter = "END:VEVENT\r\n" 
    static let dateValueParam = ";VALUE=DATE-TIME:"
    
    public static func write(calendar: Calendar) -> String {
        return calendar.events.reduce(calendarHeader) {
            $0 + write(event: $1)
        } + calendarFooter
    }
    
    static func write(event: Event) -> String {
        return event.encoded.sorted {
            $0.0 < $1.0
        }.reduce(eventHeader) {
            $0 + fold($1.0 + $1.1.icsText) + "\r\n"
        } + eventFooter
    }
    
    static func fold(_ line: String, at foldLength: Int = iCalFoldLength) -> String {
        return line.reduce("") {
            let result = $0 + String($1)
            let splitCount = result.numberOfMatches(of: .fold)
            return (result.count - splitCount) % foldLength == 0 ? result + "\r\n " : result
        }
    }
    
    static func escape(_ text: String) -> String {
        return text.replace(regex: .backslash, with: "\\\\\\\\")
            .replace(regex: .newLine, with: "\\\\n")
            .replace(regex: .semiColon, with: "\\\\;")
            .replace(regex: .comma, with: "\\\\,")
    }
}

extension Date: EventValue {
	public var icsText: String {
		return Writer.dateValueParam + Writer.dateFormatter.string(from: self)
	}
}

extension String: EventValue {
	public var icsText: String {
		return ":" + Writer.escape(self)
	}
}
