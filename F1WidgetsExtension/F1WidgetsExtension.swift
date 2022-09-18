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

    struct FixedSize {
        let horizontal: Bool
        let vertical: Bool
    }

    private let spacing: CGFloat = 10
    private let fontSize: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: spacing) {
                logoView
                Divider().frame(height: fontSize * 2)
                WidgetLabelView(text: entry.race?.raceName, fontSize: fontSize, skeletonWidth: 90, sizing: FixedSize(horizontal: false, vertical: true))
            }

            HStack(spacing: spacing) {
                WidgetLabelView(text: F1DataService.shared.daysLeftStringified(date: entry.race?.date), fontSize: fontSize, skeletonWidth: 90)
                Circle().frame(width: fontSize, height: fontSize).opacity(0.2)
                WidgetLabelView(text: entry.race?.time.convertUTCToLocal(), fontSize: fontSize)
            }

            HStack {
                WidgetLabelView(text: entry.race?.circuit.circuitName, fontSize: fontSize, sizing: FixedSize(horizontal: false, vertical: false))
            }
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
        let fontSize: CGFloat
        let skeletonWidth: CGFloat?
        let skeletonsTestOn = false
        let sizing: FixedSize

        init(text: String?, fontSize: CGFloat, skeletonWidth: CGFloat? = nil, sizing: FixedSize? = nil) {
            self.text = text
            self.fontSize = fontSize
            self.skeletonWidth = skeletonWidth
            self.sizing = sizing == nil ? FixedSize(horizontal: false, vertical: false) : sizing!
        }

        var body: some View {
            if let text = text, !skeletonsTestOn {
                Text(text)
                    .bold()
                    .font(.system(size: fontSize))
                    .fixedSize(horizontal: sizing.horizontal, vertical: sizing.vertical)
            } else {
                if let width = skeletonWidth {
                    RoundedRectangle(cornerRadius: 20)
                        .opacity(0.2)
                        .padding(0)
                        .frame(width: width)
                } else {
                    RoundedRectangle(cornerRadius: 20)
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
