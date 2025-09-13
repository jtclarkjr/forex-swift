//
//  WatchlistTableView.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/13.
//

import SwiftUI

struct WatchlistTableView: View {
    let watchlistItems: [WatchlistItem]
    let viewModel: WatchlistViewModel
    @Binding var selectedItemForDetails: WatchlistItem?
    let onDeleteItems: (IndexSet) -> Void
    let onMoveItems: (IndexSet, Int) -> Void
    
    var body: some View {
        List {
            ForEach(watchlistItems, id: \.id) { item in
                WatchlistItemRow(
                    item: item,
                    rate: viewModel.rates[item.pairString],
                    onTap: {
                        if viewModel.connectionStatus != .disconnected {
                            selectedItemForDetails = item
                        }
                    }
                )
            }
            .onDelete(perform: onDeleteItems)
            .onMove(perform: onMoveItems)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refreshRates()
        }
    }
}

#Preview {
    WatchlistTableView(
        watchlistItems: [],
        viewModel: WatchlistViewModel(),
        selectedItemForDetails: .constant(nil),
        onDeleteItems: { _ in },
        onMoveItems: { _, _ in }
    )
}