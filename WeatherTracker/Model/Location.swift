//
//  Location.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/15/24.
//

import Foundation

struct Location: Codable {
    let id: Int?
    let name: String
    let region: String
    let country: String
}
