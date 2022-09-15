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
        F1DataService.shared.getUpcomingRace { race in
            let entry = SimpleEntry(date: Date(), configuration: configuration, race: race)
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        F1DataService.shared.getUpcomingRace { race in
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, configuration: configuration, race: race)
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var race: Race?
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
                Text(entry.race?.raceName ?? "-")
                    .bold()
                    .font(.system(size: 10))
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    raceStartTextView
                    Divider()
                    Text(entry.race?.time.convertUTCToLocal() ?? "-")
                        .bold()
                        .font(.system(size: 10))
                }
                Text(entry.race?.circuit.circuitName ?? "-")
                    .bold()
                    .font(.system(size: 10))
            }
        }
        .widgetURL(URL(string: "widget://link0")!)
    }

    var raceStartTextView: some View {
        Text(daysLeftStringified())
            .bold()
            .font(.system(size: 10))
    }

    func daysLeftStringified() -> String {
        let daysLeft = Int(String(entry.race?.date ?? "").stringDateToDaysLeft()) ?? -1

        var startsInText: String = {
            switch daysLeft {
            case let x where x > 0:
                return "Starts in \(daysLeft) days"
            case let x where x == 0:
                return "🏁 Starts today!"
            case let x where x < 0:
                return ""
            default:
                return ""
            }
        }()

        return startsInText
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
