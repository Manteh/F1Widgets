//
//  Extensions.swift
//  F1Widgets
//
//  Created by Mantas Simanauskas on 2022-09-15.
//

import Foundation

// MARK: - String Extension
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
            dateFormatter.dateFormat = "HH:mm"

            return dateFormatter.string(from: date)
        }
        return self
    }

    func stringDateToDaysLeft() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date()))
        //let fromDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: NSDate(timeIntervalSince1970: 1666687181) as Date ))
        let toDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: dateFormatter.date(from: self) ?? Date()))

        guard let to = toDate, let from = fromDate else { return "" }

        let daysLeft = Calendar.current.getDaysBetween(from: from, to: to)
        return String(daysLeft)
    }
}

// MARK: - Calendar Extension
extension Calendar {
    func getDaysBetween(from: Date, to: Date) -> String {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        guard let days = numberOfDays.day else { return "" }
        return String(days)
    }
}

// MARK: - Dictionary Convertor Protocol & Extension
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
