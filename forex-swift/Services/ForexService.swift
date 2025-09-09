//
//  ForexService.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import Foundation
import Observation

enum ForexServiceError: LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case quotaExceeded
    case serviceUnavailable
    case connectionFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from forex service"
        case .invalidResponse:
            return "Invalid response format from forex service"
        case .quotaExceeded:
            return "API quota exceeded. Please try again later."
        case .serviceUnavailable:
            return "Forex service is temporarily unavailable. Please try again later."
        case .connectionFailed:
            return "Unable to connect to forex service. Please check your internet connection."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

@Observable
class ForexService {
    static let shared = ForexService()
    
    let baseURL: String
    let token: String
    let session: URLSession
    
    var connectionStatus: ConnectionStatus = .disconnected
    
    private init(baseURL: String? = nil, token: String? = nil, session: URLSession = .shared) {
        self.baseURL = baseURL ?? ProcessInfo.processInfo.environment["FOREX_SERVICE_URL"] ?? ""
        self.token = token ?? ProcessInfo.processInfo.environment["FOREX_SERVICE_TOKEN"] ?? ""
        self.session = session
        
        if ProcessInfo.processInfo.environment["FOREX_SERVICE_URL"] == nil || ProcessInfo.processInfo.environment["FOREX_SERVICE_TOKEN"] == nil {
            print("ForexService: Using fallback BASE_URL or TOKEN. Set these in your environment.")
        }
        
        // Test connection on initialization
        Task {
            await testConnection()
        }
    }
    
    // Test connection to the service
    private func testConnection() async {
        guard !baseURL.isEmpty && !token.isEmpty else {
            connectionStatus = .disconnected
            return
        }
        
        guard let url = URL(string: "\(baseURL)/rates?pair=EURUSD") else {
            connectionStatus = .disconnected
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "token")
        request.timeoutInterval = 5.0 // Shorter timeout for health check
        
        do {
            connectionStatus = .connecting
            let (_, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    connectionStatus = .connected
                case 401, 403:
                    connectionStatus = .disconnected
                default:
                    connectionStatus = .connected // Service is responding, even if with errors
                }
            } else {
                connectionStatus = .disconnected
            }
        } catch {
            connectionStatus = .disconnected
        }
    }
    
    // Fetch single forex rate
    func fetchForexRate(for pair: SupportedPair) async throws -> ForexRate {
        let urlString = "\(self.baseURL)/rates?pair=\(formatPairForAPI(pair.rawValue))"
        
        guard let url = URL(string: urlString) else {
            throw ForexServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(self.token, forHTTPHeaderField: "token")
        request.timeoutInterval = 10.0
        
        do {
            connectionStatus = .connecting
            let (data, response) = try await self.session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                connectionStatus = .disconnected
                throw ForexServiceError.connectionFailed
            }
            
            switch httpResponse.statusCode {
            case 200:
                connectionStatus = .connected
                let rates = try JSONDecoder().decode([ForexRate].self, from: data)
                guard let rate = rates.first else {
                    throw ForexServiceError.noData
                }
                return rate
                
            case 429:
                connectionStatus = .disconnected
                throw ForexServiceError.quotaExceeded
                
            case 500...599:
                connectionStatus = .disconnected
                throw ForexServiceError.serviceUnavailable
                
            default:
                connectionStatus = .disconnected
                throw ForexServiceError.connectionFailed
            }
            
        } catch {
            connectionStatus = .disconnected
            if error is ForexServiceError {
                throw error
            } else {
                throw ForexServiceError.unknown(error)
            }
        }
    }
    
    // Format pair for API (e.g., "USD/JPY" -> "USDJPY")
    private func formatPairForAPI(_ pair: String) -> String {
        return pair.replacingOccurrences(of: "/", with: "")
    }
}

