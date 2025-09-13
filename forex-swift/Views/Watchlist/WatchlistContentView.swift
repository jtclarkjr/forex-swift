//
//  WatchlistContentView.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/13.
//

import SwiftUI

struct WatchlistContentView: View {
    let watchlistItems: [WatchlistItem]
    let viewModel: WatchlistViewModel
    @Binding var showingAddPairs: Bool
    @Binding var selectedItemForDetails: WatchlistItem?
    let onDeleteItems: (IndexSet) -> Void
    let onMoveItems: (IndexSet, Int) -> Void
    
    var body: some View {
        if watchlistItems.isEmpty {
            EmptyWatchlistView(connectionStatus: viewModel.connectionStatus) {
                if viewModel.connectionStatus != .disconnected {
                    showingAddPairs = true
                }
            }
        } else {
            WatchlistTableView(
                watchlistItems: watchlistItems,
                viewModel: viewModel,
                selectedItemForDetails: $selectedItemForDetails,
                onDeleteItems: onDeleteItems,
                onMoveItems: onMoveItems
            )
        }
    }
}

#Preview {
    WatchlistContentView(
        watchlistItems: [],
        viewModel: WatchlistViewModel(),
        showingAddPairs: .constant(false),
        selectedItemForDetails: .constant(nil),
        onDeleteItems: { _ in },
        onMoveItems: { _, _ in }
    )
}