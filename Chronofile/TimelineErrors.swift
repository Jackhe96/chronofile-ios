//
//  LoadError.swift
//  Chronofile
//
//  Created by Jack He on 12/29/21.
//

import Foundation

enum TimelineErrors: Error {
    case loadingError
    case parsingError
    case writeError
}
