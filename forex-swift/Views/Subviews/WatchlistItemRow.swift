//
//  WatchlistItemRow.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import SwiftUI

struct WatchlistItemRow: View {
    let item: WatchlistItem
    let rate: ForexRate?
    let onTap: () -> Void
    
    private var priceColor: Color {
        // You could implement price change tracking here
        return .primary
    }
    
    private var formattedPrice: String {
        guard let rate = rate else { return "--" }
        return String(format: "%.5f", rate.price)
    }
    
    private var formattedSpread: String {
        guard let rate = rate else { return "--" }
        return String(format: "%.5f", rate.spread)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Currency Pair
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.pairString)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let base = item.baseCurrency, let quote = item.quoteCurrency {
                        Text("\(base.rawValue) → \(quote.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Price and Spread
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedPrice)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(priceColor)
                    
                    Text("Spread: \(formattedSpread)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Loading indicator
                if rate == nil {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    List {
        WatchlistItemRow(
            item: WatchlistItem(pair: .USDJPY),
            rate: ForexRate(
                from: "USD",
                to: "JPY", 
                bid: 149.123,
                ask: 149.125,
                price: 149.124,
                timeStamp: "2025-09-08T11:58:00Z"
            ),
            onTap: {}
        )
        
        WatchlistItemRow(
            item: WatchlistItem(pair: .EURUSD),
            rate: nil,
            onTap: {}
        )
    }
}
