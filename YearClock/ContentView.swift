//
//  ContentView.swift
//  YearClock
//
//  Created by Niklas on 2025-09-14.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Reload Widgets") {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
