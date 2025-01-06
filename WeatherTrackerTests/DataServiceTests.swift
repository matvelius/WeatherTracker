//
//  DataServiceTests.swift
//  WeatherTrackerTests
//
//  Created by Matvey Kostukovsky on 12/11/24.
//

import XCTest
@testable import WeatherTracker

final class DataServiceTests: XCTestCase {
    var dataService: (any DataServiceProtocol)!
    
    var mockKeychainHelper: (any KeychainHelperProtocol)!
    var mockNetworkService: (any NetworkServiceProtocol)!

    override func setUp() {
        super.setUp()
        mockKeychainHelper = MockKeychainHelper()
        mockNetworkService = MockNetworkService()
        dataService = DataService(keychainHelper: mockKeychainHelper,
                                  networkService: mockNetworkService)
        dataService.keychainHelper.saveAPIKeyToKeychain(apiKey: "123")
    }
    
    func testFetchSearchResults_givenEmptyCity_throwsError() async {
        await XCTAssertThrowsErrorAsync(try await dataService.fetchSearchResults(for: ""), DataServiceError.emptySearchString)
    }
    
    func testFetchSearchResults_givenCity_returnsSearchResults() async {
        mockKeychainHelper = MockKeychainHelper()
        mockNetworkService = MockNetworkService(shouldReturnSearchResults: true)
        dataService = DataService(keychainHelper: mockKeychainHelper,
                                  networkService: mockNetworkService)
        do {
            let locations = try await dataService.fetchSearchResults(for: "Tokyo")
            XCTAssertEqual(locations[0].name, "Tokyo")
        } catch {
            XCTFail("unable to fetch search results: \(error)")
        }
    }
    
    func testFetchWeather_givenEmptyCity_throwsError() async {
        await XCTAssertThrowsErrorAsync(try await dataService.fetchWeather(for: ""), DataServiceError.invalidCityName)
    }

    func testFetchWeather_givenCity_returnsWeatherData() async {
        do {
            let weather = try await dataService.fetchWeather(for: "Tokyo")
            XCTAssertEqual(weather.tempC, 32)
        } catch {
            XCTFail("unable to fetch weather data: \(error)")
        }
    }
    
    func testTransformedWeather_givenWeather_returnsWeatherWithTransformedValues() {
        let input = Weather(tempC: 25.7,
                            humidity: 75,
                            uv: 3.8,
                            feelslikeC: 24.1,
                            condition: Condition(icon: "//abc.com/123.png"))
        let output = dataService.transformedWeather(from: input)
        
        XCTAssertEqual(output.tempC, 26.0)
        XCTAssertEqual(output.uv, 4.0)
        XCTAssertEqual(output.feelslikeC, 24.0)
        XCTAssertEqual(output.condition.icon, "https://abc.com/123.png")
    }
    
    // courtesy of Artur Gruchala
    // https://arturgruchala.com/testing-async-await-exceptions/
    private func XCTAssertThrowsErrorAsync<T, R>(
        _ expression: @autoclosure () async throws -> T,
        _ errorThrown: @autoclosure () -> R,
        _ message: @autoclosure () -> String = "This method should fail",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async where R: Comparable, R: Error  {
        do {
            let _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            XCTAssertEqual(error as? R, errorThrown())
        }
    }
}
