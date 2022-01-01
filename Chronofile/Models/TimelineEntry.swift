//
//  TimelineEntry.swift
//  Chronofile
//
//  Created by Jack He on 12/29/21.
//

import Foundation

struct TimelineEntry: Identifiable, Equatable {
    let name: String
    let note: String?
    let startTime: Date
    let latitude: Double?
    let longitude: Double?

    var id: String {
        String(startTime.timeIntervalSince1970)
    }

    func toString() -> String {
        let latitude = latitude == nil ? "" : "\(latitude!)"
        let longitude = longitude == nil ? "" : "\(longitude!)"
        return "\(name)\t\(latitude)\t\(longitude)\t\(note ?? "")\t\(Int(startTime.timeIntervalSince1970))"
    }

    static func dummyEntry(startTime: Date) -> TimelineEntry {
        return TimelineEntry(name: "", note: "", startTime: startTime, latitude: nil, longitude: nil)
    }
}
