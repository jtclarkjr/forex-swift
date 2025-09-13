//
//  MockForexService.swift
//  forex-swiftTests
//
//  Created by James Clark on 2025/09/13.
//  Mock ForexService for testing
//

import Foundation
import Observation
@testable import forex_swift

@Observable
final class MockForexService {
    
    // MARK: - Mock Configuration
    var connectionStatus: ConnectionStatus = .disconnected
    var shouldThrowError = false
    var errorToThrow: ForexServiceError?
    var mockRates: [SupportedPair: ForexRate] = [:]
    var fetchDelay: TimeInterval = 0.0
    
    // MARK: - Call Tracking
    var fetchCallCount = 0
    var lastFetchedPair: SupportedPair?
    private(set) var fetchedPairs: [SupportedPair] = []
    
    // MARK: - Initialization
    init() {
        setupDefaultMockRates()
    }
    
    // MARK: - Mock Methods
    
    func fetchForexRate(for pair: SupportedPair) async throws -> ForexRate {
        fetchCallCount += 1
        lastFetchedPair = pair
        fetchedPairs.append(pair)
        
        // Simulate network delay if configured
        if fetchDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(fetchDelay * 1_000_000_000))
        }
        
        // Throw error if configured
        if shouldThrowError {
            throw errorToThrow ?? ForexServiceError.connectionFailed
        }
        
        // Return mock rate or create one if not configured
        if let mockRate = mockRates[pair] {
            return mockRate
        } else {
            return await createMockRate(for: pair)
        }
    }
    
    // MARK: - Mock Configuration Helpers
    
    func setConnectionStatus(_ status: ConnectionStatus) {
        connectionStatus = status
    }
    
    func configureMockRate(for pair: SupportedPair, rate: ForexRate) {
        mockRates[pair] = rate
    }
    
    func configureError(_ error: ForexServiceError) {
        shouldThrowError = true
        errorToThrow = error
    }
    
    func clearError() {
        shouldThrowError = false
        errorToThrow = nil
    }
    
    func reset() {
        fetchCallCount = 0
        lastFetchedPair = nil
        fetchedPairs.removeAll()
        shouldThrowError = false
        errorToThrow = nil
        connectionStatus = .disconnected
        mockRates.removeAll()
        fetchDelay = 0.0
        setupDefaultMockRates()
    }
    
    func setFetchDelay(_ delay: TimeInterval) {
        fetchDelay = delay
    }
    
    // MARK: - Private Helpers
    
    private func setupDefaultMockRates() {
        mockRates = [
            .USDJPY: ForexRate(
                from: "USD",
                to: "JPY",
                bid: 149.50,
                ask: 149.52,
                price: 149.51,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            ),
            .EURUSD: ForexRate(
                from: "EUR",
                to: "USD",
                bid: 1.0850,
                ask: 1.0852,
                price: 1.0851,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            ),
            .GBPUSD: ForexRate(
                from: "GBP",
                to: "USD",
                bid: 1.2500,
                ask: 1.2504,
                price: 1.2502,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            ),
            .AUDUSD: ForexRate(
                from: "AUD",
                to: "USD",
                bid: 0.6650,
                ask: 0.6652,
                price: 0.6651,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            ),
            .USDCAD: ForexRate(
                from: "USD",
                to: "CAD",
                bid: 1.3500,
                ask: 1.3502,
                price: 1.3501,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            ),
            .USDCHF: ForexRate(
                from: "USD",
                to: "CHF",
                bid: 0.9100,
                ask: 0.9102,
                price: 0.9101,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            ),
            .USDCNY: ForexRate(
                from: "USD",
                to: "CNY",
                bid: 7.2500,
                ask: 7.2502,
                price: 7.2501,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            ),
            .EURJPY: ForexRate(
                from: "EUR",
                to: "JPY",
                bid: 162.20,
                ask: 162.24,
                price: 162.22,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            ),
            .GBPJPY: ForexRate(
                from: "GBP",
                to: "JPY",
                bid: 186.80,
                ask: 186.85,
                price: 186.82,
                timeStamp: ISO8601DateFormatter().string(from: Date())
            )
        ]
    }
    
    @MainActor private func createMockRate(for pair: SupportedPair) -> ForexRate {
        let baseCurrency = pair.baseCurrency.rawValue
        let quoteCurrency = pair.quoteCurrency.rawValue
        
        // Generate realistic mock prices based on typical ranges
        let basePrice: Double
        switch pair {
        case .USDJPY, .EURJPY, .GBPJPY:
            basePrice = Double.random(in: 140...190)
        case .EURUSD, .GBPUSD:
            basePrice = Double.random(in: 1.0...1.3)
        case .AUDUSD:
            basePrice = Double.random(in: 0.6...0.8)
        case .USDCAD, .USDCHF:
            basePrice = Double.random(in: 0.9...1.4)
        case .USDCNY:
            basePrice = Double.random(in: 6.5...7.5)
        }
        
        let spread = basePrice * 0.0002 // 0.02% spread
        let bid = basePrice - spread / 2
        let ask = basePrice + spread / 2
        
        return ForexRate(
            from: baseCurrency,
            to: quoteCurrency,
            bid: bid,
            ask: ask,
            price: basePrice,
            timeStamp: ISO8601DateFormatter().string(from: Date())
        )
    }
}
