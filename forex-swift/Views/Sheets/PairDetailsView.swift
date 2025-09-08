//
//  PairDetailsView.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import SwiftUI

struct PairDetailsView: View {
    let item: WatchlistItem
    let rate: ForexRate
    
    @Environment(\.dismiss) private var dismiss
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(item.pairString)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let base = item.baseCurrency, let quote = item.quoteCurrency {
                            Text("\(base.rawValue) → \(quote.rawValue)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top)
                    
                    // Current Price Card
                    CardView {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Current Rate")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Text(String(format: "%.5f", rate.price))
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Bid/Ask Spread Card
                    CardView {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Bid/Ask Spread")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            HStack(spacing: 32) {
                                VStack(spacing: 8) {
                                    Text("Bid")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.5f", rate.bid))
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                
                                VStack(spacing: 8) {
                                    Text("Ask")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.5f", rate.ask))
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                
                                VStack(spacing: 8) {
                                    Text("Spread")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.5f", rate.spread))
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                            }
                        }
                    }
                    
                    // Technical Details Card
                    CardView {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Technical Details")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                DetailRow(title: "Spread %", value: String(format: "%.3f%%", rate.spreadPercentage))
                                DetailRow(
                                    title: "Last Updated",
                                    value: {
                                        let formatter = ISO8601DateFormatter()
                                        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                        if let date = formatter.date(from: rate.timeStamp) {
                                            return formatTime(date)
                                        } else {
                                            return "Invalid date"
                                        }
                                    }()
                                )
                                DetailRow(title: "Base Currency", value: rate.from)
                                DetailRow(title: "Quote Currency", value: rate.to)
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    PairDetailsView(
        item: WatchlistItem(pair: .USDJPY),
        rate: ForexRate(
            from: "USD",
            to: "JPY",
            bid: 149.123,
            ask: 149.125,
            price: 149.124,
            timeStamp: "2025-09-08T11:58:00Z"
        )
    )
}
