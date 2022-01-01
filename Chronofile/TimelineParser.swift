//
//  TimelineParser.swift
//  Chronofile
//
//  Created by Jack He on 12/30/21.
//

import Foundation

func timelineParser(data: Data) throws -> [TimelineEntry] {
    guard let text = String(data: data, encoding: .utf8) else {
        throw TimelineErrors.parsingError
    }

    let entryArrays = text.split(separator: "\n").map { row in
        row.split(separator: "\t", omittingEmptySubsequences: false)
    }
    let entries: [TimelineEntry] = entryArrays.compactMap { entryArray in
        guard
            entryArray.count == 5,
            let timeStamp = TimeInterval(entryArray[4])
        else {
            return nil
        }
        let name = String(entryArray[0])
        let latitude = entryArray[1].isEmpty ? nil : Double(entryArray[1])
        let longitude = entryArray[2].isEmpty ? nil : Double(entryArray[2])
        let note = String(entryArray[3])
        return TimelineEntry(
            name: name,
            note: note,
            startTime: Date(timeIntervalSince1970: timeStamp),
            latitude: latitude,
            longitude: longitude
        )
    }
    if entries.count != entryArrays.count {
        throw TimelineErrors.parsingError
    }
    return entries
}
