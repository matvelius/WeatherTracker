//
//  NetworkService.swift
//  WeatherTracker
//
//  Created by Matvey Kostukovsky on 12/11/24.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchData<T: Decodable>(for urlString: String) async throws -> T
}

final public class NetworkService: NetworkServiceProtocol {
    func fetchData<T: Decodable>(for urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkServiceError.unableToCreateURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpUrlResponse = response as? HTTPURLResponse,
              httpUrlResponse.statusCode == 200 else {
            throw NetworkServiceError.badResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkServiceError.unableToDecodeData
        }
    }
}

enum NetworkServiceError: Error {
    case unableToCreateURL
    case urlSessionError(String)
    case badResponse
    case unableToDecodeData
}
