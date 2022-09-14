//
//  F1WidgetsExtension.swift
//  F1WidgetsExtension
//
//  Created by Mantas Simanauskas on 2022-09-14.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct F1WidgetsExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image("f1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                Text("Singapore Grand Prix")
                    .bold()
                    .font(.system(size: 10))
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Starts in 18 days")
                        .bold()
                        .font(.system(size: 10))
                    Divider()
                    Text("14:00")
                        .bold()
                        .font(.system(size: 10))
                }
                Text("Marina Bay Street Circuit")
                    .bold()
                    .font(.system(size: 10))
            }
        }
        .widgetURL(URL(string: "widget://link0")!)
    }
}

@main
struct F1Widgets: WidgetBundle {
   var body: some Widget {
       F1WidgetsExtension()
   }
}

struct F1WidgetsExtension: Widget {
    let kind: String = "F1WidgetsExtension"

    var body: some WidgetConfiguration {
        if #available(iOSApplicationExtension 16.0, *) {
            return IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
                F1WidgetsExtensionEntryView(entry: entry)
            }
            .configurationDisplayName("Some display name")
            .description("Some description")
            .supportedFamilies([.accessoryRectangular])
        } else {
            return EmptyWidgetConfiguration()
        }
    }
}

struct F1WidgetsExtension_Previews: PreviewProvider {
    static var previews: some View {
        F1WidgetsExtensionEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
