//
//  ContentView.swift
//  Chronofile
//
//  Created by Jack He on 12/27/21.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: Store<TimelineState, TimelineAction> = Store(
        initialState: TimelineState(),
        reducer: timelineReducer,
        environment: TimelineEnvironment.live()
    )

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TimelineView(store: store)
                Spacer()
                EntryAdderView(store: store)
            }
            .padding()
            .background(.black)
            .navigationTitle(Text("Timeline"))
            .toolbar {
                NavigationLink {
                    StatsView()
                } label: {
                    Image(systemName: "eye.circle")
                }

            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
