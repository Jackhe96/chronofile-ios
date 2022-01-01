//
//  Extensions.swift
//  Chronofile
//
//  Created by Jack He on 12/28/21.
//

import Foundation
import SwiftUI
import UIKit

extension CGFloat {
    static var unit: CGFloat = 8
}

extension Date {
    enum DateFormat {
        case hoursAndMinutes

        case dayMonthAndYear

        var formatString: String {
            switch self {
            case .hoursAndMinutes:
                return "HH:mm"
            case .dayMonthAndYear:
                return "EEE, d MMM yyyy"
            }
        }
    }

    func toString(format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.formatString
        return dateFormatter.string(from: self)
    }
}

extension TimeInterval {
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }

    private var hours: Int {
        return Int(self) / 3600
    }

    var stringTime: String {
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }

    func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading
    ) -> some View {
        placeholder(when: shouldShow, alignment: alignment) { Text(text).foregroundColor(.gray) }
    }
}
