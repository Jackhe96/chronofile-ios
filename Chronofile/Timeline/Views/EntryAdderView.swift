//
//  EntryAdderView.swift
//  Chronofile
//
//  Created by Jack He on 12/28/21.
//

import ComposableArchitecture
import CoreLocation
import SwiftUI

struct EntryAdderView: View {
    let store: Store<TimelineState, TimelineAction>

    @State
    private var activityName: String = ""

    @State
    var note: String = ""

    private var buttonColor: Color {
        activityName.isEmpty ? Color.white.opacity(0.3) : Color.blue
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: .unit * 2)
                        .foregroundColor(.white.opacity(0.2))
                    VStack(alignment: .leading, spacing: .unit) {
                        TextField("", text: $activityName)
                            .foregroundColor(.white)
                            .placeholder(when: activityName.isEmpty) {
                                Text("Activity")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        Divider()
                            .background(.white)
                            .opacity(0.2)
                        TextField("", text: $note)
                            .foregroundColor(.white)
                            .placeholder(when: note.isEmpty) {
                                Text("Note")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        HStack {
                            Spacer()
                            Button {
                                let entry = TimelineEntry(
                                    name: activityName,
                                    note: note,
                                    startTime: viewStore.timelineEntries.last?.startTime ?? Date.now,
                                    latitude: viewStore.latitude,
                                    longitude: viewStore.longitude
                                )
                                viewStore.send(.addEntryTapped(entry))
                                activityName = ""
                                note = ""
                                return
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(buttonColor)
                            }
                            .disabled(activityName.isEmpty)
                        }
                    }
                    .padding()
                }
                .background(.black)
                .frame(maxHeight: 100)
            }
        }
    }
}

struct EntryAdderView_Previews: PreviewProvider {
    static var previews: some View {
        EntryAdderView(store: Store(
            initialState: TimelineState(),
            reducer: timelineReducer,
            environment: TimelineEnvironment.live())
        )
    }
}
