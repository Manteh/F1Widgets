//
//  F1DataService.swift
//  F1Widgets
//
//  Created by Mantas Simanauskas on 2022-09-14.
//

import Foundation

class F1DataService {
    static let shared = F1DataService()
    var upcomingRace: Race?

    private init() {
        getUpcomingRace { race in
            self.upcomingRace = race
        }
    }

    func getUpcomingRace(completion: @escaping (Race?) -> Void) {
        self.fetchData { data, error in
            guard let data = data else { return }
            guard let raceData = data["MRData"] as? [String: Any],
            let raceTable = raceData["RaceTable"] as? [String: Any],
            let races = raceTable["Races"] as? [[String: Any]] else { return }

            guard let upcomingRace = races.first(where: {
                $0["date"] as? String == "2022-10-02"
            }) else { return }

            guard let jsonData = try? JSONSerialization.data(withJSONObject: upcomingRace),
            let raceModel = try? JSONDecoder().decode(Race.self, from: jsonData) else { return }
            completion(raceModel)
        }
    }

    private func fetchData(completion: @escaping ([String:Any]?, Error?) -> Void) {
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


// Other
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

    func convertUTCToLocal() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.defaultDate = Date()
        dateFormatter.dateFormat = "HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = dateFormatter.date(from: self) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "H:mm"

            return dateFormatter.string(from: date)
        }
        return self
    }

    func stringDateToDaysLeft() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let toDate = dateFormatter.date(from: self) ?? Date()
        let daysLeft = Calendar.current.getDaysBetween(from: Date(), to: toDate)
        return String(daysLeft)
    }
}

extension Calendar {
    func getDaysBetween(from: Date, to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        return numberOfDays.day! + 1
    }
}
