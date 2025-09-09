//
//  WatchlistViewModel.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import Foundation
import SwiftData
import Observation
import SwiftUI

@Observable
final class WatchlistViewModel {
    // MARK: - Published Properties
    var rates: [String: ForexRate] = [:]
    var connectionStatus: ConnectionStatus { forexService.connectionStatus }
    var lastUpdated: Date?
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Private Properties
    private let forexService = ForexService.shared
    private var timer: Timer?
    private var watchedPairs: Set<SupportedPair> = []
    
    // MARK: - Public Methods
    
    /// Start streaming forex data for given pairs
    func startStreaming(with items: [WatchlistItem]) {
        let pairs = items.compactMap { $0.pair }
        guard !pairs.isEmpty else { return }
        
        watchedPairs = Set(pairs)
        isLoading = true
        errorMessage = nil
        
        // Start timer-based polling every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                await self.fetchAllRates()
            }
        }
        
        // Initial fetch
        Task {
            await fetchAllRates()
        }
    }
    
    /// Stop streaming forex data
    func stopStreaming() {
        timer?.invalidate()
        timer = nil
        isLoading = false
    }
    
    /// Add a new pair to watch
    func addPairToWatch(_ pair: SupportedPair) {
        watchedPairs.insert(pair)
        // Fetch rate immediately for new pair
        Task {
            await fetchRate(for: pair)
        }
    }
    
    /// Remove a pair from watching
    func removePairFromWatch(_ pair: SupportedPair) {
        watchedPairs.remove(pair)
        rates.removeValue(forKey: pair.rawValue)
    }
    
    /// Refresh all rates manually
    func refreshRates() async {
        guard !watchedPairs.isEmpty else { return }
        await fetchAllRates()
    }
    
    /// Get available pairs that can be added to watchlist
    func getAvailablePairs(excluding items: [WatchlistItem]) -> [SupportedPair] {
        let existingPairs = Set(items.compactMap { $0.pair })
        return SupportedPair.allCases.filter { !existingPairs.contains($0) }
    }
    
    /// Add multiple pairs to watchlist in SwiftData context
    func addPairs(_ pairs: [SupportedPair], to items: [WatchlistItem], context: ModelContext) {
        let nextOrder = (items.map { $0.order }.max() ?? -1) + 1
        
        for (index, pair) in pairs.enumerated() {
            let newItem = WatchlistItem(pair: pair, order: nextOrder + index)
            context.insert(newItem)
            addPairToWatch(pair)
        }
        
        saveContext(context)
    }
    
    /// Delete watchlist items from SwiftData context
    func deleteItems(at offsets: IndexSet, from items: [WatchlistItem], context: ModelContext) {
        for index in offsets {
            let item = items[index]
            if let pair = item.pair {
                removePairFromWatch(pair)
            }
            context.delete(item)
        }
        
        saveContext(context)
    }
    
    /// Reorder watchlist items
    func moveItems(from source: IndexSet, to destination: Int, in items: [WatchlistItem]) {
        var updatedItems = items
        updatedItems.move(fromOffsets: source, toOffset: destination)
        
        // Update the order property for all items
        for (index, item) in updatedItems.enumerated() {
            item.order = index
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchAllRates() async {
        guard !watchedPairs.isEmpty else { return }
        
        await withTaskGroup(of: Void.self) { group in
            for pair in watchedPairs {
                group.addTask {
                    await self.fetchRate(for: pair)
                }
            }
        }
        
        // Update loading state based on results
        await MainActor.run {
            if rates.count > 0 {
                isLoading = false
                errorMessage = nil
            } else {
                isLoading = false
                errorMessage = "Unable to fetch forex data"
            }
        }
    }
    
    private func fetchRate(for pair: SupportedPair) async {
        do {
            let rate = try await forexService.fetchForexRate(for: pair)
            await MainActor.run {
                rates[pair.rawValue] = rate
                
                // Parse the API timestamp and use it as lastUpdated
                let isoFormatter = ISO8601DateFormatter()
                if let apiDate = isoFormatter.date(from: rate.timeStamp) {
                    lastUpdated = apiDate
                } else {
                    lastUpdated = Date() // Fallback to current time
                }
            }
        } catch {
            await MainActor.run {
                print("Error fetching rate for \(pair.rawValue): \(error.localizedDescription)")
            }
        }
    }
    
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}

