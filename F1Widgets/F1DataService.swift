//
//  F1DataService.swift
//  F1Widgets
//
//  Created by Mantas Simanauskas on 2022-09-14.
//

import Foundation

class F1DataService {
    // MARK: - Properties
    var upcomingRace: Race?

    // MARK: - Singleton
    static let shared = F1DataService()

    // MARK: - Init
    private init() {
        getUpcomingRace { race in
            self.upcomingRace = race
        }
    }

    // MARK: - Functions
    func getUpcomingRace(completion: @escaping (Race?) -> Void) {
        self.fetchData { data, error in
            guard let data = data else { return }
            guard let raceData = data["MRData"] as? [String: Any],
            let raceTable = raceData["RaceTable"] as? [String: Any],
            let races = raceTable["Races"] as? [[String: Any]] else { return }

            guard let upcomingRace = races.first(where: {
                let dateString = String($0["date"] as? String ?? "")
                let daysLeft = dateString.stringDateToDaysLeft()
                return Int(daysLeft) ?? -1 >= 0
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

    func daysLeftStringified(date: String?) -> String {
        let daysLeft = Int(String(date ?? "-1").stringDateToDaysLeft()) ?? -1
        let startsInText: String = {
            switch daysLeft {
            case _ where daysLeft > 1:
                return "Starts in \(daysLeft) days"
            case _ where daysLeft == 1:
                return "Starts tomorrow!"
            case _ where daysLeft == 0:
                return "🏁 Starts today!"
            case _ where daysLeft < 0:
                return ""
            default:
                return ""
            }
        }()

        return startsInText
    }
}
