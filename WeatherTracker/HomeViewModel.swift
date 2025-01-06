//
//  HomeViewModel.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/15/24.
//

import Combine
import Foundation
import os

@Observable
final class HomeViewModel {
    private let dataService: DataServiceProtocol
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HomeViewModel.self)
    )
    
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var searchSubject = CurrentValueSubject<String, Never>("")
    
    var isLoading = true
    var apiKeyMissing = true
    
    var searchIsActive = false
    var searchQuery: String = "" {
        didSet {
            searchSubject.send(searchQuery.alphaOnly)
        }
    }
    var searchResults = [Location]()
    var selectedLocation: Location?
    var currentWeather: Weather? 
    
    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService
        self.apiKeyMissing = dataService.keychainHelper.getAPIKeyFromKeychain() == nil
        self.setupSearchQuerySubscription()
    }
    
    func checkCacheAndLoadWeather() async {
        do {
            isLoading = true
            let data = try dataService.cacheManager.retrieveData()
            selectedLocation = try JSONDecoder().decode(Location.self, from: data)
            if let name = selectedLocation?.name {
                currentWeather = try await dataService.fetchWeather(for: name)
            }
            isLoading = false
        } catch {
            logger.warning("unable to retrieve cached location: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    func setupSearchQuerySubscription() {
        searchSubject
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map({ string in
                self.search(for: string)
            })
            .switchToLatest() 
            .sink { [weak self] in
                guard let self else { return }
                searchResults = $0
            }
            .store(in: &cancellables)
    }
    
    func search(for string: String) -> Future<[Location], Never> {
        Future<[Location], Never> { [weak self] promise in
            self?.isLoading = true
            Task {
                do {
                    guard let results = try await self?.dataService.fetchSearchResults(for: string) else {
                        promise(.success([]))
                        self?.isLoading = false
                        self?.logger.warning("unable to fetch search results")
                        return
                    }
                    promise(.success(results))
                    self?.isLoading = false
                } catch {
                    promise(.success([]))
                    self?.isLoading = false
                    self?.logger.warning("unable to fetch search results: \(error)")
                }
            }
        }
    }
    
    func handleSelection(_ location: Location) {
        selectedLocation = location
        
        searchIsActive = false
        searchQuery = ""
        searchResults = []
        
        do {
            isLoading = true
            let data = try JSONEncoder().encode(location)
            dataService.cacheManager.cache(data)
            Task {
                currentWeather = try await dataService.fetchWeather(for: location.name)
                isLoading = false
            }
        } catch {
            logger.error("unable to cache location: \(error)")
            isLoading = false
        }
    }
    
    func storeAPIKey(_ apiKey: String) {
        apiKeyMissing = !dataService.keychainHelper.saveAPIKeyToKeychain(apiKey: apiKey)
    }
    
    func deleteStoredAPIKey() {
        dataService.keychainHelper.deleteAPIKeyFromKeychain()
    }
}
