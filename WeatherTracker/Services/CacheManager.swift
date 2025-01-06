//
//  CacheManager.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/25/24.
//

import Foundation

protocol CacheManagerProtocol {
    func cache(_ data: Data)
    func retrieveData() throws -> Data
    func removeData()
}

final public class CacheManager: CacheManagerProtocol {
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func cache(_ data: Data) {
        userDefaults.set(data, forKey: Constants.cacheKey)
    }
    
    func retrieveData() throws -> Data {
        guard let data = userDefaults.object(forKey: Constants.cacheKey) as? Data else {
            throw CacheManagerError.unableToRetrieveData
        }
        return data
    }
    
    func removeData() {
        userDefaults.set(nil, forKey: Constants.cacheKey)
    }
    
    struct Constants {
        static let cacheKey = "selectedLocation"
    }
}

enum CacheManagerError: Error {
    case unableToRetrieveData
}
