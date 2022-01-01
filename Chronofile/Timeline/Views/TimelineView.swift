//
//  TimelineView.swift
//  Chronofile
//
//  Created by Jack He on 12/29/21.
//

import ComposableArchitecture
import SwiftUI

struct TimelineView: View {
    let store: Store<TimelineState, TimelineAction>

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewReader in
                WithViewStore(store) { viewStore in
                    LazyVStack(spacing: 0) {
                        ForEach(viewStore.state.timelineEntries.indices, id: \.self) { index in
                            if !viewStore.state.timelineEntries[index].name.isEmpty {
                                getEntryView(at: index, allEntries: viewStore.timelineEntries)
                            }
                        }
                    }
                    .onAppear {
                        viewStore.send(.onAppear)
                        if viewStore.timelineEntries.count > 1 {
                            scrollViewReader.scrollTo(viewStore.timelineEntries.count - 2)
                        }
                    }
                    .onChange(of: viewStore.timelineEntries.count) { newCount in
                        scrollViewReader.scrollTo(viewStore.timelineEntries.count - 2)
                    }
                }
            }
        }
    }

    func getEntryView(at index: Int, allEntries: [TimelineEntry]) -> TimelineEntryView {
        let entry = allEntries[index]
        var duration: TimeInterval = 0
        var showDayLabel = false
        var maybeEndTime: Date?
        if index != allEntries.count - 1 {
            let nextEntry = allEntries[index + 1]
            let endTime = nextEntry.startTime
            maybeEndTime = endTime
            duration = TimeInterval(endTime.timeIntervalSince(entry.startTime))
        }
        if index != 0 {
            let previousEntry = allEntries[index - 1]
            showDayLabel = !Calendar.current.isDate(entry.startTime, equalTo: previousEntry.startTime, toGranularity: .day)
        }

        return TimelineEntryView(
            name: entry.name,
            note: entry.note,
            duration: duration,
            endTime: maybeEndTime ?? Date.now,
            showDayLabel: showDayLabel
        )
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(store: Store(
            initialState: TimelineState(timelineEntries: [
                TimelineEntry(name: "Entry 1", note: "Placeholder Note", startTime: Date(timeIntervalSince1970: 20000), latitude: nil, longitude: nil),
                TimelineEntry(name: "Entry 2", note: nil, startTime: Date(timeIntervalSince1970: 20100), latitude: nil, longitude: nil),
                TimelineEntry(name: "Entry 3", note: "Placeholder Note", startTime: Date(timeIntervalSince1970: 40000), latitude: nil, longitude: nil),
                TimelineEntry(name: "", note: "", startTime: Date(timeIntervalSince1970: 47000), latitude: nil, longitude: nil)
            ]),
            reducer: timelineReducer,
            environment: TimelineEnvironment.live()
        ))
    }
}
