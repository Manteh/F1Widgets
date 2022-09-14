//
//  ContentView.swift
//  F1Widgets
//
//  Created by Mantas Simanauskas on 2022-09-14.
//

import SwiftUI
import WidgetKit

// Hi!
protocol DictionaryConvertor {
    func toDictionary() -> [String : Any]
}

extension DictionaryConvertor {

    func toDictionary() -> [String : Any] {
        let reflect = Mirror(reflecting: self)
        let children = reflect.children
        let dictionary = toAnyHashable(elements: children)
        return dictionary
    }

    func toAnyHashable(elements: AnyCollection<Mirror.Child>) -> [String : Any] {
        var dictionary: [String : Any] = [:]
        for element in elements {
            if let key = element.label {

                if let collectionValidHashable = element.value as? [AnyHashable] {
                    dictionary[key] = collectionValidHashable
                }

                if let validHashable = element.value as? AnyHashable {
                    dictionary[key] = validHashable
                }

                if let convertor = element.value as? DictionaryConvertor {
                    dictionary[key] = convertor.toDictionary()
                }

                if let convertorList = element.value as? [DictionaryConvertor] {
                    dictionary[key] = convertorList.map({ e in
                        e.toDictionary()
                    })
                }
            }
        }
        return dictionary
    }
}

struct Race: Codable, DictionaryConvertor {
    let season: String
    let round: String
    let url: String
    let raceName: String
    let circuit: Circuit
    let date: String
    let time: String
    let firstPractice: Event
    let secondPractice: Event
    let thirdPractice: Event
    let qualifying: Event

    enum CodingKeys: String, CodingKey {
        case season
        case round
        case url
        case raceName
        case circuit = "Circuit"
        case date
        case time
        case firstPractice = "FirstPractice"
        case secondPractice = "SecondPractice"
        case thirdPractice = "ThirdPractice"
        case qualifying = "Qualifying"
    }

    struct Circuit: Codable, DictionaryConvertor {
        let circuitId: String
        let url: String
        let circuitName: String
    }

    struct Event: Codable, DictionaryConvertor {
        let date: String
        let time: String
    }
}

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
            self.fetchData { data, error in
                guard let data = data else { return }
                guard let upcomingRace = getUpcomingRace(fetchedData: data) else { return }
                self.upcomingRace = upcomingRace
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
                    .listRowBackground(Color.white)
            }
        }

        func isURL(_ urlString: String?) -> Bool {
            if let urlString = urlString {
                return urlString.isValidURL
            }
            return false
        }
    }

    func getUpcomingRace(fetchedData: [String:Any]) -> Race? {
        guard let raceData = fetchedData["MRData"] as? [String: Any],
        let raceTable = raceData["RaceTable"] as? [String: Any],
        let races = raceTable["Races"] as? [[String: Any]] else { return nil }

        guard let upcomingRace = races.first(where: {
            $0["date"] as? String == "2022-10-02"
        }) else { return nil }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: upcomingRace),
        let raceModel = try? JSONDecoder().decode(Race.self, from: jsonData) else { return nil }

        return raceModel
    }

    func fetchData(completion: @escaping ([String:Any]?, Error?) -> Void) {
        let url = URL(string:"https://ergast.com/api/f1/current.json")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                    completion(array, nil)
                }
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
