//
//  StatsView.swift
//  Chronofile
//
//  Created by Jack He on 1/1/22.
//

import SwiftUI

struct StatsView: View {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        Color.clear.background(.black)
            .navigationTitle("Statistics")
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
