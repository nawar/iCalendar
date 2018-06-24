//
//  Event.swift
//  iCalendar
//
//  Created by Michael Brown on 20/05/2017.
//  Copyright © 2017 iCalendar. All rights reserved.
//

import Foundation

public protocol EventValue {
    var icsText: String {get}
}

public struct Event {
    public let uid: String
    public let prodId: String
    public let startDate: Date
    public let endDate: Date
    public let description: String?
    public let summary: String?
    public let location: String?
    public let status: String?
    public let organizer: Person?
    public let attendees: [Person]?

    public init(uid: String, prodId: String, startDate: Date, endDate: Date, description: String? = nil, summary: String? = nil, location: String? = nil, status: String,
                organizer: Person? = nil, attendees: [Person]? = nil) {
		self.uid = uid
        self.prodId = prodId
		self.startDate = startDate
		self.endDate = endDate
		self.description = description
		self.summary = summary
		self.location = location
        self.status = status
        self.organizer = organizer
        self.attendees = attendees
	}

    init?(with encoded: [String:Any]) {
        guard let startDate = encoded[Keys.startDate] as? Date,
            let endDate = encoded[Keys.endDate] as? Date else {
                return nil
        }
        
        self.uid = encoded[Keys.uid] as? String ?? UUID().uuidString
        self.prodId = encoded[Keys.prodId] as! String
        self.startDate = startDate
        self.endDate = endDate
        description = encoded[Keys.description] as? String
        summary = encoded[Keys.summary] as? String
        location = encoded[Keys.location] as? String
        status = encoded[Keys.status] as? String
        organizer = encoded[Keys.organizer] as? Person
        attendees = encoded[Keys.attendee] as? [Person]
    }
    
    var encoded: [String:EventValue] {
        var dict: [String: EventValue] = [:]
        dict[Keys.uid] = uid
        dict[Keys.prodId] = prodId
        dict[Keys.startDate] = startDate
        dict[Keys.endDate] = endDate
        dict[Keys.description] = description
        dict[Keys.summary] = summary
        dict[Keys.location] = location
        dict[Keys.status] = status
        
        return dict
    }
}

extension Event {
    enum Keys: String {
        case uid = "UID"
        case prodId = "PRODID"
        case startDate = "DTSTART"
        case endDate = "DTEND"
        case description = "DESCRIPTION"
        case summary = "SUMMARY"
        case location = "LOCATION"
        case status = "STATUS"
        case organizer = "ORGANIZER"
        case attendee = "ATTENDEE"
    }
}
