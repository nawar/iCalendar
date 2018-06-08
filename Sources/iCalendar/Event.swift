//
//  Event.swift
//  iCalendar
//
//  Created by Michael Brown on 20/05/2017.
//  Copyright © 2017 iCalendar. All rights reserved.
//

import Foundation

protocol EventValue {
    var icsText: String {get}
}

public struct Event {
    let uid: String
    let startDate: Date
    let endDate: Date
    let description: String?
    let summary: String?
    let location: String?
	
	public init(uid: String, startDate: Date, endDate: Date, description: String? = nil, summary: String? = nil, location: String? = nil) {
		self.uid = uid
		self.startDate = startDate
		self.endDate = endDate
		self.description = description
		self.summary = summary
		self.location = location
	}

    init?(with encoded: [String:EventValue]) {
        guard let startDate = encoded[Keys.startDate] as? Date,
            let endDate = encoded[Keys.endDate] as? Date else {
                return nil
        }
        
        self.uid = encoded[Keys.uid] as? String ?? UUID().uuidString
        self.startDate = startDate
        self.endDate = endDate
        description = encoded[Keys.description] as? String
        summary = encoded[Keys.summary] as? String
        location = encoded[Keys.location] as? String
    }
    
    var encoded: [String:EventValue] {
        var dict: [String: EventValue] = [:]
        dict[Keys.uid] = uid
        dict[Keys.startDate] = startDate
        dict[Keys.endDate] = endDate
        dict[Keys.description] = description
        dict[Keys.summary] = summary
        dict[Keys.location] = location
        
        return dict
    }
}

extension Event {
    enum Keys: String {
        case uid = "UID"
        case startDate = "DTSTART"
        case endDate = "DTEND"
        case description = "DESCRIPTION"
        case summary = "SUMMARY"
        case location = "LOCATION"
    }
}
