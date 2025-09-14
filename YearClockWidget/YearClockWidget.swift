//
//  YearClockWidget.swift
//  YearClockWidget
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

struct YearClockWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            YearDialView(overrideDate: entry.date)
                .padding(8)
        }
    }
}

struct YearClockWidget: Widget {
    let kind: String = "YearClockWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            YearClockWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
