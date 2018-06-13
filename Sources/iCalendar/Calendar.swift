//
//  Calendar.swift
//  iCalendar
//
//  Created by Michael Brown on 20/05/2017.
//  Copyright © 2017 iCalendar. All rights reserved.
//

import Foundation

public struct Calendar {
    public let events: [Event]
	
	public init(events: [Event]) {
		self.events = events
	}
}

func +(lhs: Calendar, rhs: Calendar) -> Calendar {
    return Calendar(events: (lhs.events + rhs.events).sorted() {
        return $0.startDate > $1.startDate
    })
}
    

