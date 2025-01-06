//
//  MockKeychainHelper.swift
//  WeatherTrackerTests
//
//  Created by Matvey Kostukovsky on 12/15/24.
//

import Foundation
@testable import WeatherTracker

class MockKeychainHelper: KeychainHelperProtocol {
    var shouldBeMissingAPIKey: Bool
    
    init(shouldBeMissingAPIKey: Bool = false) {
        self.shouldBeMissingAPIKey = shouldBeMissingAPIKey
    }
    
    func saveAPIKeyToKeychain(apiKey: String) -> Bool {
        return true
    }
    
    func getAPIKeyFromKeychain() -> String? {
        return shouldBeMissingAPIKey ? nil : "ABC123"
    }
    
    func deleteAPIKeyFromKeychain() -> Bool {
        return true
    }
}
