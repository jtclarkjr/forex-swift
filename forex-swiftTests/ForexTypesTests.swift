//
//  ForexTypesTests.swift
//  forex-swiftTests
//
//  Created by James Clark on 2025/09/13.
//  Unit tests for ForexTypes model
//

import Testing
import Foundation
@testable import forex_swift

struct ForexTypesTests {
    
    // MARK: - SupportedCurrency Tests
    
    @Test("Supported currency enum contains all expected values")
    func testSupportedCurrencyValues() {
        let expectedCurrencies = ["USD", "JPY", "EUR", "GBP", "AUD", "CAD", "CHF", "CNY"]
        let actualCurrencies = SupportedCurrency.allCases.map { $0.rawValue }.sorted()
        
        #expect(actualCurrencies == expectedCurrencies.sorted())
    }
    
    @Test("Supported currency can be initialized from string")
    func testSupportedCurrencyInitialization() {
        #expect(SupportedCurrency(rawValue: "USD") == .USD)
        #expect(SupportedCurrency(rawValue: "JPY") == .JPY)
        #expect(SupportedCurrency(rawValue: "INVALID") == nil)
    }
    
    // MARK: - SupportedPair Tests
    
    @Test("Supported pair contains all expected pairs")
    func testSupportedPairValues() {
        let expectedPairs = [
            "USD/JPY", "EUR/USD", "GBP/USD", "AUD/USD", 
            "USD/CAD", "USD/CHF", "USD/CNY", "EUR/JPY", "GBP/JPY"
        ]
        let actualPairs = SupportedPair.allCases.map { $0.rawValue }.sorted()
        
        #expect(actualPairs == expectedPairs.sorted())
    }
    
    @Test("Base currency extraction works correctly")
    @MainActor func testBaseCurrencyExtraction() {
        #expect(SupportedPair.USDJPY.baseCurrency == .USD)
        #expect(SupportedPair.EURUSD.baseCurrency == .EUR)
        #expect(SupportedPair.GBPUSD.baseCurrency == .GBP)
        #expect(SupportedPair.EURJPY.baseCurrency == .EUR)
    }
    
    @Test("Quote currency extraction works correctly")
    @MainActor func testQuoteCurrencyExtraction() {
        #expect(SupportedPair.USDJPY.quoteCurrency == .JPY)
        #expect(SupportedPair.EURUSD.quoteCurrency == .USD)
        #expect(SupportedPair.GBPUSD.quoteCurrency == .USD)
        #expect(SupportedPair.EURJPY.quoteCurrency == .JPY)
    }
    
    // MARK: - ConnectionStatus Tests
    
    @Test("Connection status enum contains expected values")
    func testConnectionStatusValues() {
        let expectedValues = ["connected", "connecting", "disconnected"]
        let actualValues = [
            ConnectionStatus.connected.rawValue,
            ConnectionStatus.connecting.rawValue,
            ConnectionStatus.disconnected.rawValue
        ].sorted()
        
        #expect(actualValues == expectedValues.sorted())
    }
    
    // MARK: - ForexRate Tests
    
    @Test("ForexRate computes pair string correctly")
    @MainActor func testForexRatePairString() {
        let rate = ForexRate(
            from: "USD",
            to: "JPY",
            bid: 149.50,
            ask: 149.52,
            price: 149.51,
            timeStamp: "2025-09-13T03:00:00Z"
        )
        
        #expect(rate.pair == "USD/JPY")
    }
    
    @Test("ForexRate computes spread correctly")
    @MainActor func testForexRateSpread() {
        let rate = ForexRate(
            from: "EUR",
            to: "USD",
            bid: 1.0850,
            ask: 1.0852,
            price: 1.0851,
            timeStamp: "2025-09-13T03:00:00Z"
        )
        
        #expect(rate.spread == 0.0002)
    }
    
    @Test("ForexRate computes spread percentage correctly")
    @MainActor func testForexRateSpreadPercentage() {
        let rate = ForexRate(
            from: "GBP",
            to: "USD",
            bid: 1.2500,
            ask: 1.2504,
            price: 1.2502,
            timeStamp: "2025-09-13T03:00:00Z"
        )
        
        let expectedSpreadPercentage = (0.0004 / 1.2502) * 100
        #expect(abs(rate.spreadPercentage - expectedSpreadPercentage) < 0.001)
    }
    
    @Test("ForexRate handles zero spread")
    @MainActor func testForexRateZeroSpread() {
        let rate = ForexRate(
            from: "USD",
            to: "CAD",
            bid: 1.3500,
            ask: 1.3500,
            price: 1.3500,
            timeStamp: "2025-09-13T03:00:00Z"
        )
        
        #expect(rate.spread == 0.0)
        #expect(rate.spreadPercentage == 0.0)
    }
    
    // MARK: - APIResponse Tests
    
    @Test("APIResponse handles successful response")
    @MainActor func testAPIResponseSuccess() throws {
        let rate = ForexRate(
            from: "USD",
            to: "JPY",
            bid: 149.50,
            ask: 149.52,
            price: 149.51,
            timeStamp: "2025-09-13T03:00:00Z"
        )
        
        let response = APIResponse(success: true, data: rate, error: nil)
        
        #expect(response.success == true)
        #expect(response.data != nil)
        #expect(response.error == nil)
    }
    
    @Test("APIResponse handles error response")
    @MainActor func testAPIResponseError() {
        let response: APIResponse<ForexRate> = APIResponse(
            success: false,
            data: nil,
            error: "API quota exceeded"
        )
        
        #expect(response.success == false)
        #expect(response.data == nil)
        #expect(response.error == "API quota exceeded")
    }
}
