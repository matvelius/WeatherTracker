//
//  Weather.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/12/24.
//

import Foundation

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Weather: Decodable {
    let tempC: Float
    let humidity: Int
    let uv: Float
    let feelslikeC: Float
    let condition: Condition
}

struct Condition: Decodable {
    let icon: String
}
