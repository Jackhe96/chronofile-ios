//
//  LogEntry.swift
//  Chronofile
//
//  Created by Jack He on 12/28/21.
//

import SwiftUI

struct TimelineEntryView: View {
    let name: String

    let note: String?

    let duration: TimeInterval

    let endTime: Date

    let showDayLabel: Bool

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: .unit / 2) {
                if showDayLabel {
                    ZStack {
                        RoundedRectangle(cornerRadius: .unit * 1.5)
                            .foregroundColor(.white.opacity(0.2))
                        Text("\(endTime.toString(format: .dayMonthAndYear))")
                            .font(.footnote)
                            .padding(
                                EdgeInsets(
                                    top: .unit / 2,
                                    leading: .unit,
                                    bottom: .unit / 2,
                                    trailing: .unit
                                )
                            )
                    }
                    .fixedSize(horizontal: true, vertical: true)
                    Spacer()
                        .frame(height: .unit)
                }
                HStack(alignment: .firstTextBaseline, spacing: .unit) {
                    Text(name)
                    Text(note ?? "")
                        .opacity(0.7)
                        .font(.system(size: 15))
                    Spacer()
                    Text("\(duration.stringTime)")
                }
                Text("\(endTime.toString(format: .hoursAndMinutes))")
                    .font(.footnote)
                    .opacity(0.7)
            }
            .padding(.vertical)
        }
        .foregroundColor(.white)
        .background(.black)
    }
}

struct TimelineEntry_Previews: PreviewProvider {
    static var previews: some View {
        TimelineEntryView(
            name: "Placeholder Name",
            note: "Placeholder Note",
            duration: 10,
            endTime: Date(timeIntervalSince1970: 100000),
            showDayLabel: true
        )
    }
}
