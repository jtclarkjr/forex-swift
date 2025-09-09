//
//  AddPairsView.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import SwiftUI

struct AddPairsView: View {
    let availablePairs: [SupportedPair]
    let connectionStatus: ConnectionStatus
    let onAddPairs: ([SupportedPair]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPairs: Set<SupportedPair> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if availablePairs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("All Pairs Added")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("You've already added all available currency pairs to your watchlist.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(availablePairs, id: \.self) { pair in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pair.rawValue)
                                        .font(.headline)
                                    
                                    Text("\(pair.baseCurrency.rawValue) → \(pair.quoteCurrency.rawValue)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedPairs.contains(pair) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                togglePair(pair)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Add Currency Pairs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAddPairs(Array(selectedPairs))
                        dismiss()
                    }
                    .disabled(selectedPairs.isEmpty || connectionStatus == .disconnected)
                    .foregroundColor((selectedPairs.isEmpty || connectionStatus == .disconnected) ? .gray : .blue)
                }
            }
        }
    }
    
    private func togglePair(_ pair: SupportedPair) {
        if selectedPairs.contains(pair) {
            selectedPairs.remove(pair)
        } else {
            selectedPairs.insert(pair)
        }
    }
}

#Preview {
    AddPairsView(
        availablePairs: [.USDJPY, .EURUSD, .GBPUSD],
        connectionStatus: .connected,
        onAddPairs: { pairs in
            print("Adding pairs: \(pairs)")
        }
    )
}
