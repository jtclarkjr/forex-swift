//
//  WatchlistMainView.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/13.
//

import SwiftUI

struct WatchlistMainView: View {
    let watchlistItems: [WatchlistItem]
    let viewModel: WatchlistViewModel
    @Binding var showingAddPairs: Bool
    @Binding var selectedItemForDetails: WatchlistItem?
    let onDeleteItems: (IndexSet) -> Void
    let onMoveItems: (IndexSet, Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ConnectionStatusBar(
                status: viewModel.connectionStatus, 
                lastUpdated: viewModel.lastUpdated
            )
            
            WatchlistContentView(
                watchlistItems: watchlistItems,
                viewModel: viewModel,
                showingAddPairs: $showingAddPairs,
                selectedItemForDetails: $selectedItemForDetails,
                onDeleteItems: onDeleteItems,
                onMoveItems: onMoveItems
            )
        }
        .navigationTitle("Forex Watchlist")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            WatchlistToolbarContent(
                watchlistItems: watchlistItems,
                viewModel: viewModel,
                showingAddPairs: $showingAddPairs
            )
        }
    }
}

#Preview {
    NavigationView {
        WatchlistMainView(
            watchlistItems: [],
            viewModel: WatchlistViewModel(),
            showingAddPairs: .constant(false),
            selectedItemForDetails: .constant(nil),
            onDeleteItems: { _ in },
            onMoveItems: { _, _ in }
        )
    }
}