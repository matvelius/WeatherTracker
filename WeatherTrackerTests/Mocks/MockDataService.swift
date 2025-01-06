//
//  MockDataService.swift
//  WeatherTrackerTests
//
//  Created by Matvey Kostukovsky on 12/23/24.
//

import Foundation
@testable import WeatherTracker

class MockDataService: DataServiceProtocol {
    var cacheManager: any CacheManagerProtocol
    var keychainHelper: any KeychainHelperProtocol
    
    private let shouldThrowError: Bool
    
    init(keychainHelper: KeychainHelperProtocol,
         shouldThrowError: Bool = false) {
        self.cacheManager = MockCacheManager()
        self.keychainHelper = MockKeychainHelper()
        self.shouldThrowError = shouldThrowError
    }
    
    func fetchSearchResults(for input: String) async throws -> [Location] {
        guard !shouldThrowError else {
            throw DataServiceError.emptySearchString
        }
        
        return [Location(id: 1, name: "Tokyo", region: "Kantō", country: "Japan")]
    }
    
    func fetchWeather(for city: String) async throws -> Weather {
        guard !shouldThrowError else {
            throw DataServiceError.invalidCityName
        }
        
        return Weather(tempC: 32, humidity: 80, uv: 0.1, feelslikeC: 31, condition: Condition(icon: "iconUrl"))
    }
    
    func transformedWeather(from weather: Weather) -> Weather {
        return Weather(tempC: 32, humidity: 80, uv: 0, feelslikeC: 31, condition: Condition(icon: "iconUrl"))
    }
}
