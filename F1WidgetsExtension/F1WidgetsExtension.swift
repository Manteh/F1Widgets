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
    private let minSpacerLength: CGFloat = 5
    private let placeholderHeight: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: minSpacerLength) {
            HStack(spacing: 0) {
                logoView
                Spacer(minLength: minSpacerLength)
                Divider()
                Spacer(minLength: minSpacerLength)
                WidgetLabelView(text: entry.race?.raceName, shouldBeMultiline: true)
                Spacer(minLength: 0)
            }

            HStack(spacing: 0) {
                WidgetLabelView(text: F1DataService.shared.daysLeftStringified(date: entry.race?.date), skeletonWidth: 90)
                Spacer(minLength: minSpacerLength)
                Divider()
                Spacer(minLength: minSpacerLength)
                WidgetLabelView(text: entry.race?.time.convertUTCToLocal())
                Spacer(minLength: 0)
            }

            HStack {
                WidgetLabelView( text: entry.race?.circuit.circuitName)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "widget://link0")!)
    }

    // MARK: - Mini Views
    var logoView: some View {
        Image("f1")
            .resizable()
            .scaledToFit()
    }

    struct WidgetLabelView: View {
        let text: String?
        let skeletonWidth: CGFloat?
        let shouldBeMultiline: Bool
        let skeletonsTestOn = false

        init(text: String?, skeletonWidth: CGFloat? = nil, shouldBeMultiline: Bool = false) {
            self.text = text
            self.skeletonWidth = skeletonWidth
            self.shouldBeMultiline = shouldBeMultiline
        }

        var body: some View {
            if let text = text, !skeletonsTestOn {
                Text(text)
                    .bold()
                    .font(.system(size: 10))
                    .fixedSize(horizontal: shouldBeMultiline ? false : true, vertical: true)
            } else {
                if let width = skeletonWidth {
                    Rectangle()
                        .opacity(0.2)
                        .padding(0)
                        .frame(width: width)
                } else {
                    Rectangle()
                        .opacity(0.2)
                        .padding(0)
                }
            }
        }
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
