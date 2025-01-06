//
//  HomeViewModelTests.swift
//  WeatherTrackerTests
//
//  Created by Matvey Kostukovsky on 12/23/24.
//

import Combine
import XCTest
@testable import WeatherTracker

final class HomeViewModelTests: XCTestCase {
    var homeViewModel: HomeViewModel!
    
    var mockDataService: (any DataServiceProtocol)!
    var mockKeychainHelper: (any KeychainHelperProtocol)!
    
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockKeychainHelper = MockKeychainHelper(shouldBeMissingAPIKey: true)
        mockDataService = MockDataService(keychainHelper: mockKeychainHelper)
        homeViewModel = HomeViewModel(dataService: mockDataService)
    }
    
    func testSearch_whenGivenString_returnsFutureWithLocation() async {
        let future = homeViewModel.search(for: "Tokyo")
        let locations = await future.value
        XCTAssertEqual(locations.count, 1)
    }
    
    func testSearchSubject_whenSentString_returnsSearchResults() {
        let expectation = XCTestExpectation(description: "Search results should not be empty.")
        
        homeViewModel.searchSubject
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { _ in
                XCTAssertFalse(self.homeViewModel.searchResults.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        homeViewModel.searchQuery = "Tokyo"
        wait(for: [expectation], timeout: 1)
    }
    
    func testSearch_whenSearchReturnsNoResults_returnsEmptyArray() async {
        mockDataService = MockDataService(keychainHelper: mockKeychainHelper, shouldThrowError: true)
        homeViewModel = HomeViewModel(dataService: mockDataService)
        let future = homeViewModel.search(for: "")
        let locations = await future.value
        XCTAssertTrue(locations.isEmpty)
    }
    
    func testSearch_whenGivenString_returnsResults() async {
        let future = homeViewModel.search(for: "Tokyo")
        let locations = await future.value
        XCTAssertFalse(locations.isEmpty)
    }
    
    func testHandleSelection_whenGivenLocation_updatesUI() {
        homeViewModel.handleSelection(Location(id: 1, name: "Tokyo", region: "Kantō", country: "Japan"))
        XCTAssertNotNil(homeViewModel.selectedLocation)
        XCTAssertFalse(homeViewModel.searchIsActive)
        XCTAssertTrue(homeViewModel.searchQuery.isEmpty)
        XCTAssertTrue(homeViewModel.searchResults.isEmpty)
    }

    func testStoreAPIKey_givenKey_setsBoolToTrue() {
        homeViewModel.deleteStoredAPIKey()
        homeViewModel.storeAPIKey("ABC123")
        XCTAssertFalse(homeViewModel.apiKeyMissing)
    }

}
