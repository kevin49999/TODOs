//
//  TODOsWidget.swift
//  TODOsWidget
//
//  Created by Kevin Johnson on 12/6/20.
//  Copyright © 2020 Kevin Johnson. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: Date(), today: TodoList(classification: .daysOfWeek, name: "Monday"), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TodayEntry) -> ()) {
        // wot..
        let entry = TodayEntry(date: Date(), today: TodoList(classification: .daysOfWeek, name: "Monday"), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let week = try loadCurrentWeek()
            let entries: [TodayEntry] = week.map { .init(
                date: $0.dateCreated,
                today: $0,
                configuration: ConfigurationIntent()
            )}
            let timeline = Timeline(
                entries: entries,
                policy: .atEnd
            )
            completion(timeline)
        } catch {
            print(error)
        }
    }

    // MARK: - Helper

    private func loadCurrentWeek() throws -> [TodoList] {
        let url = AppGroup.todos.containerURL.appendingPathComponent("week")
        let data = try Data(contentsOf: url)
        let week = try JSONDecoder().decode([TodoList].self, from: data)
        week.forEach { print($0.name) }
        return week
    }
}

// MARK: - TodoEntry

struct TodayEntry: TimelineEntry {
    let date: Date
    let today: TodoList
    let configuration: ConfigurationIntent

    init(
        date: Date = Date.todayYearMonthDay(),
        today: TodoList,
        configuration: ConfigurationIntent
    ) {
        self.date = date
        self.today = today
        self.configuration = configuration
    }
}

// MARK: - TODOsWidgetEntryView

struct TODOsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.today.name)
        VStack(alignment: .leading) {
            ForEach(entry.today.todos, id: \.self) { todo in
                Text(todo.text)
            }
        }
    }
}

// MARK: - TODOsWidget

@main
struct TODOsWidget: Widget {
    let kind: String = "TODOsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TODOsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TODOs for today")
        .description("Show the list of TODOs for today")
        .supportedFamilies([.systemSmall,.systemMedium,.systemLarge])
    }
}

// MARK: - Previews

struct TODOsWidget_Previews: PreviewProvider {
    static var previews: some View {
        TODOsWidgetEntryView(
            entry: TodayEntry(
                date: Date(),
                today: TodoList(classification: .daysOfWeek, name: "Monday"),
                configuration: ConfigurationIntent()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}