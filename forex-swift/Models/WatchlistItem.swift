//
//  WatchlistItem.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import Foundation
import SwiftData

@Model
final class WatchlistItem {
    @Attribute(.unique) var id: String
    var pairString: String
    var isActive: Bool
    var order: Int
    var dateAdded: Date
    
    init(pair: SupportedPair, order: Int = 0) {
        self.id = UUID().uuidString
        self.pairString = pair.rawValue
        self.isActive = true
        self.order = order
        self.dateAdded = Date()
    }
    
    var pair: SupportedPair? {
        return SupportedPair(rawValue: pairString)
    }
    
    @MainActor
    var baseCurrency: SupportedCurrency? {
        return pair?.baseCurrency
    }
    
    @MainActor
    var quoteCurrency: SupportedCurrency? {
        return pair?.quoteCurrency
    }
}
