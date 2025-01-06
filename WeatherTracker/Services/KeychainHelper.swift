//
//  KeychainHelper.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/15/24.
//

import Foundation
import Security

protocol KeychainHelperProtocol {
    @discardableResult
    func saveAPIKeyToKeychain(apiKey: String) -> Bool
    func getAPIKeyFromKeychain() -> String?
    @discardableResult
    func deleteAPIKeyFromKeychain() -> Bool
}

final public class KeychainHelper: KeychainHelperProtocol {
    private let service = "com.matveycodes.WeatherTracker"
    
    public func saveAPIKeyToKeychain(apiKey: String) -> Bool {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: apiKey.data(using: .utf8, allowLossyConversion: false)!
        ]

        // Delete any existing item
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new key
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    func getAPIKeyFromKeychain() -> String? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data,
               let apiKey = String(data: retrievedData, encoding: .utf8) {
                return apiKey
            }
        }
        return nil
    }
    
    @discardableResult
    func deleteAPIKeyFromKeychain() -> Bool {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        
        return status == errSecSuccess
    }
}
