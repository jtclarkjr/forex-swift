//
//  WatchlistItemTests.swift
//  forex-swiftTests
//
//  Created by James Clark on 2025/09/13.
//  Unit tests for WatchlistItem model
//

import Testing
import Foundation
import SwiftData
@testable import forex_swift

@MainActor
struct WatchlistItemTests {
    
    // MARK: - Initialization Tests
    
    @Test("WatchlistItem initializes with correct values")
    func testWatchlistItemInitialization() {
        let pair = SupportedPair.USDJPY
        let order = 5
        let item = WatchlistItem(pair: pair, order: order)
        
        #expect(item.pairString == "USD/JPY")
        #expect(item.isActive == true)
        #expect(item.order == 5)
        // dateAdded should be initialized to a valid Date
        #expect(!item.id.isEmpty)
    }
    
    @Test("WatchlistItem initializes with default order")
    func testWatchlistItemDefaultOrder() {
        let pair = SupportedPair.EURUSD
        let item = WatchlistItem(pair: pair)
        
        #expect(item.order == 0)
    }
    
    @Test("WatchlistItem generates unique IDs")
    func testWatchlistItemUniqueIDs() {
        let item1 = WatchlistItem(pair: .USDJPY)
        let item2 = WatchlistItem(pair: .EURUSD)
        
        #expect(item1.id != item2.id)
    }
    
    // MARK: - Pair Conversion Tests
    
    @Test("WatchlistItem converts back to SupportedPair correctly")
    func testPairConversion() {
        let originalPair = SupportedPair.GBPUSD
        let item = WatchlistItem(pair: originalPair)
        
        #expect(item.pair == originalPair)
    }
    
    @Test("WatchlistItem handles all supported pairs")
    func testAllSupportedPairs() {
        for supportedPair in SupportedPair.allCases {
            let item = WatchlistItem(pair: supportedPair)
            
            #expect(item.pairString == supportedPair.rawValue)
            #expect(item.pair == supportedPair)
        }
    }
    
    @Test("WatchlistItem handles invalid pair string")
    func testInvalidPairString() {
        let item = WatchlistItem(pair: .USDJPY)
        // Manually set an invalid pair string to test the computed property
        item.pairString = "INVALID/PAIR"
        
        #expect(item.pair == nil)
    }
    
    // MARK: - Currency Property Tests
    
    @Test("Base currency property returns correct currency")
    func testBaseCurrency() {
        let item1 = WatchlistItem(pair: .USDJPY)
        let item2 = WatchlistItem(pair: .EURUSD)
        let item3 = WatchlistItem(pair: .GBPJPY)
        
        #expect(item1.baseCurrency == .USD)
        #expect(item2.baseCurrency == .EUR)
        #expect(item3.baseCurrency == .GBP)
    }
    
    @Test("Quote currency property returns correct currency")
    func testQuoteCurrency() {
        let item1 = WatchlistItem(pair: .USDJPY)
        let item2 = WatchlistItem(pair: .EURUSD)
        let item3 = WatchlistItem(pair: .EURJPY)
        
        #expect(item1.quoteCurrency == .JPY)
        #expect(item2.quoteCurrency == .USD)
        #expect(item3.quoteCurrency == .JPY)
    }
    
    @Test("Currency properties handle invalid pairs")
    func testCurrencyPropertiesWithInvalidPair() {
        let item = WatchlistItem(pair: .USDJPY)
        item.pairString = "INVALID"
        
        #expect(item.baseCurrency == nil)
        #expect(item.quoteCurrency == nil)
    }
    
    // MARK: - Date Property Tests
    
    @Test("Date added is set to current time on initialization")
    func testDateAdded() {
        let beforeCreation = Date()
        let item = WatchlistItem(pair: .USDJPY)
        let afterCreation = Date()
        
        #expect(item.dateAdded >= beforeCreation)
        #expect(item.dateAdded <= afterCreation)
    }
    
    // MARK: - Property Modification Tests
    
    @Test("WatchlistItem properties can be modified")
    func testPropertyModification() {
        let item = WatchlistItem(pair: .USDJPY, order: 0)
        
        // Test modifying order
        item.order = 10
        #expect(item.order == 10)
        
        // Test modifying isActive
        item.isActive = false
        #expect(item.isActive == false)
        
        // Test modifying pairString
        item.pairString = "EUR/USD"
        #expect(item.pairString == "EUR/USD")
        #expect(item.pair == .EURUSD)
    }
    
    // MARK: - SwiftData Model Container Tests
    
    @Test("WatchlistItem can be used in model container")
    func testSwiftDataModelContainer() throws {
        let schema = Schema([WatchlistItem.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        
        let item = WatchlistItem(pair: .USDJPY)
        context.insert(item)
        
        #expect(context.hasChanges)
    }
}
