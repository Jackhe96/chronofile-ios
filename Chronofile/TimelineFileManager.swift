//
//  FileManager.swift
//  Chronofile
//
//  Created by Jack He on 12/29/21.
//

import Foundation
import ComposableArchitecture

private let fileManager = FileManager.default

private let fileName: String = "chronofile.tsv"

private var fileUrl: URL {
    fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
}

func loadTimeline(parser: @escaping (Data) throws -> [TimelineEntry]) -> Effect<[TimelineEntry], TimelineErrors> {
    return FileGetterPublisher(fileURL: fileUrl)
        .mapError { _ in TimelineErrors.loadingError }
        .tryMap { data in try parser(data) }
        .mapError { _ in TimelineErrors.parsingError }
        .eraseToEffect()
}

func writeTimeline(timeline: [TimelineEntry]) -> Effect<Void, TimelineErrors> {
    let text = timeline.map { $0.toString() }.joined(separator: "\n")
    
    guard let textData = text.data(using: .utf8) else {
        return Effect(error: .writeError)
    }

    return FileWriterPublisher(fileURL: fileUrl, data: textData)
        .mapError { _ in TimelineErrors.writeError }
        .eraseToEffect()
}
