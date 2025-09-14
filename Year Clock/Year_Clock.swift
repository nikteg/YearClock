//
//  Year_Clock.swift
//  Year Clock
//
//  Created by Niklas on 2025-09-14.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct Year_ClockEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            YearDialView()
                .padding(8)
        }
    }
}

struct Year_Clock: Widget {
    let kind: String = "Year_Clock"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Year_ClockEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

#if DEBUG
#Preview(as: .systemSmall) {
    Year_Clock()
} timeline: {
    SimpleEntry(date: .now, configuration: .init())
    SimpleEntry(date: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 1))!, configuration: .init())
    SimpleEntry(date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 1))!, configuration: .init())
}
#endif
