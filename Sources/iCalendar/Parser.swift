//
//  Parser.swift
//  iCalendar
//
//  Updated by Nawar on 07/06/2018
//  Created by Michael Brown on 20/05/2017.
//  Copyright © 2017 iCalendar. All rights reserved.
//

import Foundation

public typealias EventDictionary = [String:EventValue]

public struct Context {
    var inCalendar = 0
    var inEvent = 0
    var inTimeZone = 0
    var inStandard = 0
    var inDayLight = 0
    var inAlarm = 0
    var values = [String:Any]()
    var events = [Event]()
}

struct ParsedLine {
    let key: String
    let params: [String:String]?
    let value: String
}

public enum ParserError: Error {
    case invalidObjectType
    case nestedCalendar
    case nestedEvent
    case endBeforeBegin
    case noColon(String)
    case noKey(String)
    case requiredEventFieldsMissing([String:Any])
    case calAddressKeyOutsideOfEvent(String)
    case invalid(String)
    case noParams(String)
}

public struct Parser {
    struct Key {
        static let begin = "BEGIN"
        static let end = "END"
    }
    
    static let DateKeys = ["DTSTART", "DTEND", "DTSTAMP"]
    static let dateTimeFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        return formatter
    }()
    
    static let tzidFormatter: DateFormatter = {
      let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss"
        return formatter
    }()
    
    // calAddress components
    static let CalAddressKeys = [ "ATTENDEE", "ORGANIZER" ]
    static let CalendarUserType = [
        "INDIVIDUAL",   // An individual
        "GROUP",        // A group of individuals
        "RESOURCE",     // A physical resource
        "ROOM",         // A room resource
        "UNKNOWN" ]

    // Calendar Components
    enum VType: String {
        case calendar = "VCALENDAR"
        case event = "VEVENT"
        case note = "VTODO"
        case journal = "VJOURNAL"
        case freeBusy = "VFREEBUSY"
        case timeZone = "VTIMEZONE"
        case alarm = "VALARM"
    }
    
    // VTIZ Components
    enum VTiz: String {
        case timezone = "VTIMEZONE"
        case standard = "STANDARD"
        case daylight = "DAYLIGHT"
    }
    
    public static func lines(ics: String) -> [String] {
        let newLine: Character = "\n"
        let normalized = ics.replace(regex: .fold, with: "")
            .replace(regex: .lineEnding, with: String(newLine))
        
        return normalized.split(separator: newLine).map(String.init)
    }
    
    static func unescape(_ text: String) -> String {
        return text.replace(regex: .escComma, with: ",")
            .replace(regex: .escSemiColon, with: ";")
            .replace(regex: .escNewline, with: "\n")
            .replace(regex: .escBackslash, with: "\\\\")
    }
    
    public static func dateString(from date: String, params: [String:String]?) -> String {
        if let params = params,
            params["VALUE"] == "DATE" {
            return date + "T120000Z"
        }
        
        /*
         if date.last != "Z" {
         return date + "Z"
         }
         */
        
        return date
    }
    
    static func parse(date: String, params: [String:String]?) -> Date? {
        
        if let params = params,
            let tzid = params["TZID"] {
            if let timeZone = DateFormatter.translate(fromWindowsTimezone: tzid) {
                tzidFormatter.timeZone = TimeZone(identifier: timeZone)
            } else {
                tzidFormatter.timeZone = TimeZone(identifier: tzid)
            }
            
            let formattedDate = tzidFormatter.date(from: date)
            tzidFormatter.timeZone = TimeZone.current // reset the time zone
            return formattedDate

        } else {
            
            return dateTimeFormatter.date(from: dateString(from: date, params: params))
            
        }
    }
    
    static func parse(params: [String]?) -> [String:String]? {
        guard let params = params else {
            return Optional.none
        }
        
        return params.reduce([String:String]()) {
            resultIn, param in
            var result = resultIn
            let split = param.split(separator: "=", maxSplits: 1)
            
            if let paramKey = split.first,
                let paramVal = split.last {
                result[String(paramKey)] = String(paramVal)
            }
            return result
        }
    }
    
    static func parse(line: String) -> (ParsedLine?, ParserError?) {
        let valueSplit = line.split(separator: ":", maxSplits: 1)

        // The split is usually 2 or 1 if there's no value for that field
        guard 1...2 ~= valueSplit.count,
            let vsFirst = valueSplit.first
            else { return (nil,ParserError.noColon(line)) }
        
        // in case it's optional, we give it an empty string
        let vsLast = valueSplit.count == 1 ? "" : valueSplit.last!
        let value = String(vsLast)
        let paramsSplit = vsFirst.split(separator: ";")

        guard paramsSplit.count > 0,
            let psFirst = paramsSplit.first else { return (nil,ParserError.noKey(line)) }
        
        let params = paramsSplit.count > 1 ? paramsSplit.suffix(from: 1).map(String.init) : nil
        let key = String(psFirst)
        
        return (ParsedLine(key: key, params: parse(params: params), value: value), nil)
    }
    
    static func parse(lines: [String]) -> (Calendar?, ParserError?) {
        do {
            let parsedCtx = try lines.reduce(Context()) {
                ctxIn, line in
                
                guard let parsedLine = parse(line: line).0 else { throw ParserError.invalid(line) }
                var ctx = ctxIn
                
                switch parsedLine.key {
                case Key.begin:
                    
                    // check if it's a calendar components (starts with V)
                    if let vtype = VType(rawValue: parsedLine.value) {
                        
                        switch vtype {
                        case .calendar:
                            ctx.inCalendar += 1
                            if ctx.inCalendar > 1  { throw ParserError.nestedCalendar }
                        case .event:
                            ctx.inEvent += 1
                            if ctx.inEvent > 1 { throw ParserError.nestedEvent }
                        case .alarm:
                            ctx.inAlarm += 1
                        default: ()
                        }
                        
                    } else if let vtiz = VTiz(rawValue: parsedLine.value) {
                        switch vtiz {
                        case .timezone:
                            // An individual "VTIMEZONE" calendar component MUST be specified for
                            // each unique "TZID" parameter value specified in the iCalendar object.
                            ctx.inTimeZone += 1
                        case .standard:
                            ctx.inStandard += 1
                        case .daylight:
                            ctx.inDayLight += 1
                        }
                    } else {
                        throw ParserError.invalidObjectType
                    }
                    
                case Key.end:
                    
                    // check if it's a calendar components (starts with V)
                    if let vtype = VType(rawValue: parsedLine.value) {
                        switch vtype {
                        case .calendar:
                            ctx.inCalendar -= 1
                            if ctx.inCalendar != 0 { throw ParserError.endBeforeBegin }
                        case .event:
                            ctx.inEvent -= 1
                            if ctx.inEvent != 0 { throw ParserError.endBeforeBegin }
                            
                            guard let event = Event(with: ctx.values) else {
                                throw ParserError.requiredEventFieldsMissing(ctx.values)
                            }
                            
                            ctx.events.append(event)
                            ctx.values.removeAll(keepingCapacity: true)
                        case .alarm:
                            ctx.inAlarm -= 1
                        default: ()
                        }
                    } else if let vtiz = VTiz(rawValue: parsedLine.value) {
                        switch vtiz {
                        case .timezone:
                            ctx.inTimeZone -= 1
                        case .standard:
                            ctx.inStandard -= 1
                        case .daylight:
                            ctx.inDayLight -= 1
                        }
                    } else {
                        throw ParserError.invalidObjectType
                    }
                
                case let key where DateKeys.contains(key):
                    
                    if ctx.inEvent > 0 {
                        if let date = parse(date: parsedLine.value, params: parsedLine.params) {
                            ctx.values[key] = date
                        } else {
                            ctx.values[key] = parsedLine.value
                        }
                    } else if ctx.inStandard > 0 || ctx.inDayLight > 0 {
                    }
                    
                case let key where CalAddressKeys.contains(key):
                    guard ctx.inEvent > 0 else { throw ParserError.calAddressKeyOutsideOfEvent(line) }
                    guard let params = parsedLine.params else { throw ParserError.noParams(line) }

                    switch key {
                    case "ORGANIZER":
                        let organizer = Organizer(vCalAddress: parsedLine.value, commonName: params["CN"]!)
                        ctx.values[key] = organizer
                    case "ATTENDEE":
                        
                        // if CUTYPE is mentioned and it's anything other than INDIVIDUAL then skip the processing
                        if let ctype = params["CUTYPE"], ctype != "INDIVIDUAL" { break  }
                        
                        let attendee = Attendee(vCalAddress: parsedLine.value, commonName: params["CN"]!)
                        if let attendeeValue = ctx.values[key] as? [Person] {
                            ctx.values[key] = attendeeValue + [attendee]
                        } else {
                            ctx.values[key] = [attendee]
                        }
                        
                    default: ()
                    }

                case let key:
                    
                    // break with anything that is inside a VTIMEZONE
                    guard ctx.inTimeZone == 0 || ctx.inDayLight == 0 || ctx.inStandard == 0 else { break }
                    
                    // ignore everything inside an VALARM
                    guard ctx.inAlarm == 0 else { break }
                    
                    ctx.values[key] = unescape(parsedLine.value)
                }
                
                return ctx
            }
            
            return (calendar: Calendar(events: parsedCtx.events),error: nil)
        } catch let error as ParserError  {
            return (nil, error)
        } catch let error {
            let errMsg = "Unexpected Error during parsing: \(error)"
            print(errMsg)
            return (nil, ParserError.invalid(errMsg))
        }
    }
    
    public static func parse(ics: String) -> (Calendar?, ParserError?) {
        return ics |> lines |> parse
    }
}


