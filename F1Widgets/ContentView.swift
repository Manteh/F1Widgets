//
//  ContentView.swift
//  F1Widgets
//
//  Created by Mantas Simanauskas on 2022-09-14.
//

import SwiftUI
import WidgetKit

struct F1ListRow: View {
    var key: String
    var value: String

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "smallcircle.filled.circle")
                Text(key)
            }
            Spacer()
            Text(value).bold()
        }
        .font(.system(size: 12))
    }
}

struct ContentView: View {
    @State var upcomingRace: Race?

    var body: some View {
        VStack {
            if let upcomingRace = upcomingRace {
                VStack {
                    List {
                        // MARK: - General
                        F1ListSectionView(
                            header: { logo },
                            data: upcomingRace.toDictionary().filter({ item in
                                guard let _ = item.value as? String else {
                                    return false
                                }
                                return true
                            })
                        )

                        // MARK: - Circuit
                        F1ListSectionView(
                            header: { Text("Circuit") },
                            data: upcomingRace.circuit.toDictionary()
                        )

                        // MARK: - Events
                        F1ListSectionView(
                            header: { Text("First Practice") },
                            data: upcomingRace.firstPractice.toDictionary()
                        )

                        F1ListSectionView(
                            header: { Text("Second Practice") },
                            data: upcomingRace.secondPractice.toDictionary()
                        )

                        F1ListSectionView(
                            header: { Text("Third Practice") },
                            data: upcomingRace.thirdPractice.toDictionary()
                        )

                        F1ListSectionView(
                            header: { Text("Qualifying") },
                            data: upcomingRace.qualifying.toDictionary()
                        )
                    }
                    .listStyle(.insetGrouped)

                    Spacer()
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            F1DataService.shared.getUpcomingRace { race in
                self.upcomingRace = race
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    // MARK: - Views
    var logo: some View {
        HStack {
            Image("f1")
                .resizable()
                .scaledToFit()
                .frame(height: 30)
                .padding(50)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    struct F1ListSectionView<Content: View>: View {
        @State var header: () -> Content
        @State var data: [String: Any]

        init(header: @escaping () -> Content, data: [String: Any]) {
            self.header = header
            self.data = data
        }

        var body: some View {
            Section {
                ForEach(Array(data), id: \.key) { child in
                    if isURL(child.value as? String) {
                        Button {
                            UIApplication.shared.open(URL(string: child.value as! String)!) { _ in }
                        } label: {
                            rowContent(child: child)
                        }
                    } else {
                        rowContent(child: child)
                    }
                }
            } header: { header() }
        }

        private struct rowContent: View {
            @State var child: Dictionary<String, Any>.Element

            var body: some View {
                F1ListRow(key: child.key, value: child.value as? String ?? "")
            }
        }

        func isURL(_ urlString: String?) -> Bool {
            if let urlString = urlString {
                return urlString.isValidURL
            }
            return false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
