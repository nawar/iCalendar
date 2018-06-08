//
//  Parser.swift
//  iCalendar
//
//  Updated by Nawar on 07/06/2018
//  Created by Michael Brown on 20/05/2017.
//  Copyright © 2017 iCalendar. All rights reserved.
//

import Foundation

typealias EventDictionary = [String:EventValue]

struct Context {
    var inCalendar = 0
    var inEvent = 0
    var values = EventDictionary()
    var events = [Event]()
}

struct ParsedLine {
    let key: String
    let params: [String:String]?
    let value: String
}

enum ParserError: Error {
    case invalidObjectType
    case nestedCalendar
    case nestedEvent
    case endBeforeBegin
    case noColon(String)
    case noKey(String)
    case requiredEventFieldsMissing(EventDictionary)
    case dateKeyOutsideOfEvent(String)
    case invalid(String)
}

struct Parser {
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

    enum VType: String {
        case calendar = "VCALENDAR"
        case event = "VEVENT"
    }
    
    static func lines(ics: String) -> [String] {
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
    
    static func dateString(from date: String, params: [String:String]?) -> String {
        if let params = params,
            params["VALUE"] == "DATE" {
            return date + "T120000Z"
        }
        
        if date.last != "Z" {
            return date + "Z"
        }
        
        return date
    }
    
    static func parse(date: String, params: [String:String]?) -> Date? {
        return dateTimeFormatter.date(from: dateString(from: date, params: params))
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
        guard valueSplit.count == 2,
            let vsFirst = valueSplit.first,
            let vsLast = valueSplit.last else { return (nil,ParserError.noColon(line)) }
        
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
                
                let parsedLine = parse(line: line).0!
                var ctx = ctxIn

                switch parsedLine.key {
                case Key.begin:
                    guard let vtype = VType(rawValue: parsedLine.value) else { throw ParserError.invalidObjectType }
                    switch vtype {
                    case .calendar:
                        ctx.inCalendar += 1
                        if ctx.inCalendar > 1  { throw ParserError.nestedCalendar }
                    case .event:
                        ctx.inEvent += 1
                        if ctx.inEvent > 1 { throw ParserError.nestedEvent }
                    }
                case Key.end:
                    guard let vtype = VType(rawValue: parsedLine.value) else { throw ParserError.invalidObjectType }
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
                    }
                case let key where DateKeys.contains(key):
                    guard ctx.inEvent > 0 else { throw ParserError.dateKeyOutsideOfEvent(line) }
                    if let date = parse(date: parsedLine.value, params: parsedLine.params) {
                        ctx.values[key] = date
                    }
                    else {
                        ctx.values[key] = parsedLine.value
                    }
                case let key:
                    guard ctx.inEvent > 0 else { break }
                    ctx.values[key] = unescape(parsedLine.value)
                }
                
                return ctx
            }
            
            return (Calendar(events: parsedCtx.events),nil)
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
