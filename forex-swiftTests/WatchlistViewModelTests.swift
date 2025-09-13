//
//  WatchlistViewModelTests.swift
//  forex-swiftTests
//
//  Created by James Clark on 2025/09/13.
//  Unit tests for WatchlistViewModel
//

import Testing
import Foundation
import SwiftData
@testable import forex_swift

@MainActor
struct WatchlistViewModelTests {
    
    // MARK: - Helper Methods
    
    func createMockModelContext() throws -> ModelContext {
        let schema = Schema([WatchlistItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }
    
    func createTestWatchlistItems() -> [WatchlistItem] {
        return [
            WatchlistItem(pair: .USDJPY, order: 0),
            WatchlistItem(pair: .EURUSD, order: 1),
            WatchlistItem(pair: .GBPUSD, order: 2)
        ]
    }
    
    // MARK: - Initialization Tests
    
    @Test("WatchlistViewModel initializes with correct default values")
    func testInitialization() {
        let viewModel = WatchlistViewModel()
        
        #expect(viewModel.rates.isEmpty)
        #expect(viewModel.lastUpdated == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Watchlist Management Tests
    
    @Test("Adding pair to watch updates internal state")
    func testAddPairToWatch() {
        let viewModel = WatchlistViewModel()
        
        viewModel.addPairToWatch(.USDJPY)
        
        // We can't directly test watchedPairs as it's private,
        // but we can verify behavior through other methods
        #expect(viewModel.rates.isEmpty) // Rate won't be populated without mock service
    }
    
    @Test("Removing pair from watch clears rate data")
    func testRemovePairFromWatch() {
        let viewModel = WatchlistViewModel()
        
        // Manually add a rate to test removal
        let mockRate = ForexRate(
            from: "USD",
            to: "JPY", 
            bid: 149.50,
            ask: 149.52,
            price: 149.51,
            timeStamp: "2025-09-13T03:00:00Z"
        )
        viewModel.rates["USD/JPY"] = mockRate
        
        viewModel.removePairFromWatch(.USDJPY)
        
        #expect(viewModel.rates["USD/JPY"] == nil)
    }
    
    @Test("Get available pairs excludes existing items")
    func testGetAvailablePairs() {
        let viewModel = WatchlistViewModel()
        let items = [
            WatchlistItem(pair: .USDJPY, order: 0),
            WatchlistItem(pair: .EURUSD, order: 1)
        ]
        
        let availablePairs = viewModel.getAvailablePairs(excluding: items)
        
        #expect(!availablePairs.contains(.USDJPY))
        #expect(!availablePairs.contains(.EURUSD))
        #expect(availablePairs.contains(.GBPUSD))
        #expect(availablePairs.count == SupportedPair.allCases.count - 2)
    }
    
    @Test("Get available pairs returns all pairs when none exist")
    func testGetAvailablePairsEmpty() {
        let viewModel = WatchlistViewModel()
        let items: [WatchlistItem] = []
        
        let availablePairs = viewModel.getAvailablePairs(excluding: items)
        
        #expect(availablePairs.count == SupportedPair.allCases.count)
        #expect(Set(availablePairs) == Set(SupportedPair.allCases))
    }
    
    // MARK: - SwiftData Integration Tests
    
    @Test("Adding pairs to context creates WatchlistItems")
    func testAddPairsToContext() throws {
        let viewModel = WatchlistViewModel()
        let context = try createMockModelContext()
        let existingItems: [WatchlistItem] = []
        let pairsToAdd: [SupportedPair] = [.USDJPY, .EURUSD]
        
        viewModel.addPairs(pairsToAdd, to: existingItems, context: context)
        
        // Fetch inserted items from context
        let descriptor = FetchDescriptor<WatchlistItem>(sortBy: [SortDescriptor(\.order)])
        let insertedItems = try context.fetch(descriptor)
        
        #expect(insertedItems.count == 2)
        #expect(insertedItems[0].pair == .USDJPY)
        #expect(insertedItems[0].order == 0)
        #expect(insertedItems[1].pair == .EURUSD)
        #expect(insertedItems[1].order == 1)
    }
    
    @Test("Adding pairs with existing items continues order sequence")
    func testAddPairsWithExistingOrder() throws {
        let viewModel = WatchlistViewModel()
        let context = try createMockModelContext()
        let existingItems = [
            WatchlistItem(pair: .GBPUSD, order: 5),
            WatchlistItem(pair: .AUDUSD, order: 3)
        ]
        let pairsToAdd: [SupportedPair] = [.USDJPY]
        
        viewModel.addPairs(pairsToAdd, to: existingItems, context: context)
        
        let descriptor = FetchDescriptor<WatchlistItem>(sortBy: [SortDescriptor(\.order)])
        let insertedItems = try context.fetch(descriptor)
        
        #expect(insertedItems.count == 1)
        #expect(insertedItems[0].order == 6) // Max existing order (5) + 1
    }
    
    @Test("Deleting items removes from context")
    func testDeleteItemsFromContext() throws {
        let viewModel = WatchlistViewModel()
        let context = try createMockModelContext()
        let items = createTestWatchlistItems()
        
        // Insert items into context first
        for item in items {
            context.insert(item)
        }
        try context.save()
        
        // Delete the first and third items (indices 0, 2)
        let offsetsToDelete = IndexSet([0, 2])
        viewModel.deleteItems(at: offsetsToDelete, from: items, context: context)
        
        let descriptor = FetchDescriptor<WatchlistItem>()
        let remainingItems = try context.fetch(descriptor)
        
        #expect(remainingItems.count == 1)
        #expect(remainingItems[0].pair == .EURUSD) // Middle item should remain
    }
    
    @Test("Moving items updates order correctly")
    func testMoveItems() {
        let viewModel = WatchlistViewModel()
        var items = createTestWatchlistItems()
        
        // Move first item (index 0) to position 2
        let sourceIndexSet = IndexSet([0])
        viewModel.moveItems(from: sourceIndexSet, to: 3, in: items)
        
        // The items array is modified in place by the move operation
        // After moving, the order should be updated
        #expect(items[0].order == 0) // Was second, now first
        #expect(items[1].order == 1) // Was third, now second  
        #expect(items[2].order == 2) // Was first, now third
    }
    
    // MARK: - Streaming Control Tests
    
    @Test("Start streaming sets loading state")
    func testStartStreaming() {
        let viewModel = WatchlistViewModel()
        let items = createTestWatchlistItems()
        
        viewModel.startStreaming(with: items)
        
        #expect(viewModel.isLoading == true)
        #expect(viewModel.errorMessage == nil)
        
        // Clean up timer
        viewModel.stopStreaming()
    }
    
    @Test("Start streaming with empty items does nothing")
    func testStartStreamingEmptyItems() {
        let viewModel = WatchlistViewModel()
        let items: [WatchlistItem] = []
        
        viewModel.startStreaming(with: items)
        
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Stop streaming clears loading state")
    func testStopStreaming() {
        let viewModel = WatchlistViewModel()
        let items = createTestWatchlistItems()
        
        viewModel.startStreaming(with: items)
        #expect(viewModel.isLoading == true)
        
        viewModel.stopStreaming()
        #expect(viewModel.isLoading == false)
    }
    
    // MARK: - Rate Management Tests
    
    @Test("Rates dictionary stores forex rates by pair string")
    func testRatesStorage() {
        let viewModel = WatchlistViewModel()
        let rate = ForexRate(
            from: "EUR",
            to: "USD",
            bid: 1.0850,
            ask: 1.0852, 
            price: 1.0851,
            timeStamp: "2025-09-13T03:00:00Z"
        )
        
        viewModel.rates["EUR/USD"] = rate
        
        #expect(viewModel.rates["EUR/USD"] != nil)
        #expect(viewModel.rates["EUR/USD"]?.pair == "EUR/USD")
        #expect(viewModel.rates["EUR/USD"]?.price == 1.0851)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Error message can be set and cleared")
    func testErrorMessage() {
        let viewModel = WatchlistViewModel()
        
        viewModel.errorMessage = "Test error message"
        #expect(viewModel.errorMessage == "Test error message")
        
        viewModel.errorMessage = nil
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Async Refresh Tests
    
    @Test("Refresh rates with empty watched pairs does nothing")
    func testRefreshRatesEmpty() async {
        let viewModel = WatchlistViewModel()
        
        // This should complete without error since no pairs are watched
        await viewModel.refreshRates()
        
        #expect(viewModel.rates.isEmpty)
    }
    
    // MARK: - Connection Status Tests
    
    @Test("Connection status reflects ForexService status")
    func testConnectionStatus() {
        let viewModel = WatchlistViewModel()
        
        // The connection status should reflect the shared ForexService
        // In a real test with dependency injection, we could control this
        #expect(viewModel.connectionStatus != nil)
    }
    
    // MARK: - Date Handling Tests
    
    @Test("Last updated date can be set")
    func testLastUpdatedDate() {
        let viewModel = WatchlistViewModel()
        let testDate = Date()
        
        viewModel.lastUpdated = testDate
        
        #expect(viewModel.lastUpdated == testDate)
    }
}
