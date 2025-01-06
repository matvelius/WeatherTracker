//
//  MockNetworkService.swift
//  WeatherTrackerTests
//
//  Created by Matvey Kostukovsky on 12/12/24.
//

import Foundation

@testable import WeatherTracker

class MockNetworkService: NetworkServiceProtocol {
    var shouldThrowError: Bool
    var shouldReturnSearchResults: Bool
    
    init(shouldThrowError: Bool = false, shouldReturnSearchResults: Bool = false) {
        self.shouldThrowError = shouldThrowError
        self.shouldReturnSearchResults = shouldReturnSearchResults
    }
    
    func fetchData<T: Decodable>(for urlString: String) async throws -> T {
        if shouldThrowError {
            throw NetworkServiceError.badResponse
        }

        let location = Location(id: 1, name: "Tokyo", region: "Kantō", country: "Japan")
        if shouldReturnSearchResults {
            return [location] as! T
        }
        
        let weather = Weather(tempC: 32, humidity: 80, uv: 0.1, feelslikeC: 31, condition: Condition(icon: "iconUrl"))
        return WeatherResponse(location: location, current: weather) as! T
    }
}
