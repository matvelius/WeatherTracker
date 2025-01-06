//
//  MockCacheManager.swift
//  WeatherTrackerTests
//
//  Created by Matvey Kostukovsky on 12/25/24.
//

import Foundation
@testable import WeatherTracker

class MockCacheManager: CacheManagerProtocol {
    let shouldThrowError: Bool
    
    init(shouldThrowError: Bool = false) {
        self.shouldThrowError = shouldThrowError
    }
    
    func cache(_ data: Data) {}
    
    func retrieveData() throws -> Data {
        if shouldThrowError {
            throw CacheManagerError.unableToRetrieveData
        }
        return Data()
    }
    
    func removeData() {}
}
