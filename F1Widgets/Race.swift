//
//  Race.swift
//  F1Widgets
//
//  Created by Mantas Simanauskas on 2022-09-15.
//

import Foundation

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

    struct Circuit: Codable, DictionaryConvertor {
        let circuitId: String
        let url: String
        let circuitName: String
    }

    struct Event: Codable, DictionaryConvertor {
        let date: String
        let time: String
    }

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
}
