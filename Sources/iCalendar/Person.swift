//
//  Attendee.swift
//  iCalendar
//
//  Created by Nawar Nory on 2018-06-13.
//

import Foundation

public class Person {
    public let vCalAddress: String
    public let commonName: String
    
    init(vCalAddress: String, commonName: String) {
        self.vCalAddress = vCalAddress
        self.commonName = commonName
    }
    
    public func getEmailFromCalAddress() -> String? {
        let splits = vCalAddress.split(separator: ":", maxSplits: 1)
        if splits.first == "mailto", let last = splits.last {
            return String(last)
        }
        
        return nil
    }
}

public class Attendee : Person { }

public class Organizer : Person { }


