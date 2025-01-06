//
//  DataService.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/11/24.
//

import Foundation

protocol DataServiceProtocol {
    var cacheManager: CacheManagerProtocol { get }
    var keychainHelper: KeychainHelperProtocol { get }
    
    func fetchSearchResults(for input: String) async throws -> [Location]
    func fetchWeather(for city: String) async throws -> Weather
    func transformedWeather(from weather: Weather) -> Weather
}

final public class DataService: DataServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    let cacheManager: CacheManagerProtocol
    let keychainHelper: KeychainHelperProtocol
        
    init(cacheManager: CacheManagerProtocol = CacheManager(),
         keychainHelper: KeychainHelperProtocol = KeychainHelper(),
         networkService: NetworkServiceProtocol = NetworkService()) {
        self.cacheManager = cacheManager
        self.keychainHelper = keychainHelper
        self.networkService = networkService
    }
    
    func fetchSearchResults(for input: String) async throws -> [Location] {
        guard !input.isEmpty else {
            throw DataServiceError.emptySearchString
        }
        
        let urlString = try searchUrlString(for: input)
        let locations: [Location] = try await networkService.fetchData(for: urlString)
        return locations
    }
    
    func fetchWeather(for city: String) async throws -> Weather {
        guard !city.isEmpty else {
            throw DataServiceError.invalidCityName
        }
        
        let urlString = try weatherUrlString(for: city)
        let weatherResponse: WeatherResponse = try await networkService.fetchData(for: urlString)
        return transformedWeather(from: weatherResponse.current)
    }
    
    func transformedWeather(from weather: Weather) -> Weather {
        let tempC = weather.tempC.rounded()
        let feelslikeC = weather.feelslikeC.rounded()
        let uv = weather.uv.rounded()
        
        let originalIconUrl = weather.condition.icon
        let fixedIconUrl = "https:" + originalIconUrl
        let condition = Condition(icon: fixedIconUrl)
        
        return Weather(tempC: tempC,
                       humidity: weather.humidity,
                       uv: uv,
                       feelslikeC: feelslikeC,
                       condition: condition)
    }
    
    private func searchUrlString(for input: String) throws -> String {
        guard let apiKey = keychainHelper.getAPIKeyFromKeychain() else {
            throw DataServiceError.unableToRetrieveAPIKey
        }
        
        return Constants.baseUrlString
                + Constants.searchAndAPIPrefixString
                + apiKey
                + "&q=\(input)"
    }
        
    private func weatherUrlString(for city: String) throws -> String {
        guard let apiKey = keychainHelper.getAPIKeyFromKeychain() else {
            throw DataServiceError.unableToRetrieveAPIKey
        }
        
        return Constants.baseUrlString
                + Constants.currentWeatherAndAPIPrefixString
                + apiKey
                + "&q=\(city)"
                + Constants.currentWeatherSuffixString
    }
    
    struct Constants {
        static let baseUrlString = "https://api.weatherapi.com/v1/"
        static let searchAndAPIPrefixString = "search.json?key="
        static let currentWeatherAndAPIPrefixString = "current.json?key="
        static let currentWeatherSuffixString = "&aqi=no"
    }
}

enum DataServiceError: Error, Comparable {
    case unableToRetrieveAPIKey
    case emptySearchString
    case invalidCityName
}
