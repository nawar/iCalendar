//
//  Extension.swift
//  iCalendar
//
//  Created by Nawar Nory on 2018-06-16.
//

import Foundation

extension DateFormatter {
    
    /// This function just returns the long time zone name (used by Microsoft) to it's more standard one
    class func translate(fromWindowsTimezone timezoneName: String) -> String? {
        let timezoneDictionary = [
            "AUS Central Standard Time" : "Australia/Darwin",
            "Afghanistan Standard Time" : "Asia/Kabul",
            "Alaskan Standard Time" : "America/Anchorage",
            "Arab Standard Time" : "Asia/Riyadh",
            "Arabic Standard Time" : "Asia/Baghdad",
            "Argentina Standard Time" : "America/Buenos_Aires",
            "Atlantic Standard Time" : "America/Halifax",
            "Azerbaijan Standard Time" : "Asia/Baku",
            "Azores Standard Time" : "Atlantic/Azores",
            "Bahia Standard Time" : "America/Bahia",
            "Bangladesh Standard Time" : "Asia/Dhaka",
            "Canada Central Standard Time" : "America/Regina",
            "Cape Verde Standard Time" : "Atlantic/Cape_Verde",
            "Caucasus Standard Time" : "Asia/Yerevan",
            "Cen. Australia Standard Time" : "Australia/Adelaide",
            "Central America Standard Time" : "America/Guatemala",
            "Central Asia Standard Time" : "Asia/Almaty",
            "Central Brazilian Standard Time" : "America/Cuiaba",
            "Central Europe Standard Time" : "Europe/Budapest",
            "Central European Standard Time" : "Europe/Warsaw",
            "Central Pacific Standard Time" : "Pacific/Guadalcanal",
            "Central Standard Time" : "America/Chicago",
            "Central Standard Time (Mexico)" : "America/Mexico_City",
            "China Standard Time" : "Asia/Shanghai",
            "Dateline Standard Time" : "Etc/GMT+12",
            "E. Africa Standard Time" : "Africa/Nairobi",
            "AUS Eastern Standard Time" : "Australia/Brisbane",
            "E. Europe Standard Time" : "Asia/Nicosia",
            "E. South America Standard Time" : "America/Sao_Paulo",
            "Eastern Standard Time" : "America/New_York",
            "Egypt Standard Time" : "Africa/Cairo",
            "Ekaterinburg Standard Time" : "Asia/Yekaterinburg",
            "FLE Standard Time" : "Europe/Kiev",
            "Fiji Standard Time" : "Pacific/Fiji",
            "GMT Standard Time" : "Europe/London",
            "GTB Standard Time" : "Europe/Bucharest",
            "Georgian Standard Time" : "Asia/Tbilisi",
            "Greenland Standard Time" : "America/Godthab",
            "Greenwich Standard Time" : "Atlantic/Reykjavik",
            "Hawaiian Standard Time" : "Pacific/Honolulu",
            "India Standard Time" : "Asia/Calcutta",
            "Iran Standard Time" : "Asia/Tehran",
            "Israel Standard Time" : "Asia/Jerusalem",
            "Jordan Standard Time" : "Asia/Amman",
            "Kaliningrad Standard Time" : "Europe/Kaliningrad",
            "Korea Standard Time" : "Asia/Seoul",
            "Mauritius Standard Time" : "Indian/Mauritius",
            "Middle East Standard Time" : "Asia/Beirut",
            "Montevideo Standard Time" : "America/Montevideo",
            "Morocco Standard Time" : "Africa/Casablanca",
            "Mountain Standard Time" : "America/Denver",
            "Mountain Standard Time (Mexico)" : "America/Chihuahua",
            "Myanmar Standard Time" : "Asia/Rangoon",
            "N. Central Asia Standard Time" : "Asia/Novosibirsk",
            "Namibia Standard Time" : "Africa/Windhoek",
            "Nepal Standard Time" : "Asia/Katmandu",
            "New Zealand Standard Time" : "Pacific/Auckland",
            "Newfoundland Standard Time" : "America/St_Johns",
            "North Asia East Standard Time" : "Asia/Irkutsk",
            "North Asia Standard Time" : "Asia/Krasnoyarsk",
            "Pacific SA Standard Time" : "America/Santiago",
            "Pacific Standard Time" : "America/Los_Angeles",
            "Pacific Standard Time (Mexico)" : "America/Santa_Isabel",
            "Pakistan Standard Time" : "Asia/Karachi",
            "Paraguay Standard Time" : "America/Asuncion",
            "Romance Standard Time" : "Europe/Paris",
            "Russian Standard Time" : "Europe/Moscow",
            "SA Eastern Standard Time" : "America/Cayenne",
            "SA Pacific Standard Time" : "America/Bogota",
            "SA Western Standard Time" : "America/La_Paz",
            "SE Asia Standard Time" : "Asia/Bangkok",
            "Samoa Standard Time" : "Pacific/Apia",
            "Singapore Standard Time" : "Asia/Singapore",
            "South Africa Standard Time" : "Africa/Johannesburg",
            "Sri Lanka Standard Time" : "Asia/Colombo",
            "Syria Standard Time" : "Asia/Damascus",
            "Taipei Standard Time" : "Asia/Taipei",
            "Tasmania Standard Time" : "Australia/Hobart",
            "Tokyo Standard Time" : "Asia/Tokyo",
            "Tonga Standard Time" : "Pacific/Tongatapu",
            "Turkey Standard Time" : "Europe/Istanbul",
            "US Eastern Standard Time" : "America/Indianapolis",
            "US Mountain Standard Time" : "America/Phoenix",
            "UTC" : "Etc/GMT",
            "UTC+12" : "Etc/GMT-12",
            "UTC-02" : "Etc/GMT+2",
            "UTC-11" : "Etc/GMT+11",
            "Ulaanbaatar Standard Time" : "Asia/Ulaanbaatar",
            "Venezuela Standard Time" : "America/Caracas",
            "Vladivostok Standard Time" : "Asia/Vladivostok",
            "W. Australia Standard Time" : "Australia/Perth",
            "W. Central Africa Standard Time" : "Africa/Lagos",
            "W. Europe Standard Time" : "Europe/Berlin",
            "West Asia Standard Time" : "Asia/Tashkent",
            "West Pacific Standard Time" : "Pacific/Port_Moresby",
            "Yakutsk Standard Time" : "Asia/Yakutsk"
        ]
        
        if let value = timezoneDictionary[timezoneName] { // check if we have it in the key
            return value
        } else if let item = timezoneDictionary.first(where: { (k,v) in v.lowercased() == timezoneName.lowercased() }) {
            // check if we have it in the values
            return item.value
        }
        
        return nil
    }
}
