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

        // Generate a timeline: one entry at the start of each of the next 12 months
        // starting from the beginning of the current month. This keeps the widget
        // refreshed on month boundaries rather than hourly.
        let calendar = Calendar.current
        let now = Date()
        let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now

        for monthOffset in 0..<12 {
            if let monthStart = calendar.date(byAdding: .month, value: monthOffset, to: startOfThisMonth) {
                entries.append(SimpleEntry(date: monthStart, configuration: configuration))
            }
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
