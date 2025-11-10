//
//  ContentView.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WatchlistItem.order, order: .forward) private var watchlistItems: [WatchlistItem]
    
    @State private var viewModel = WatchlistViewModel()
    @State private var showingAddPairs = false
    @State private var selectedItemForDetails: WatchlistItem?

    var body: some View {
        NavigationSplitView {
            WatchlistMainView(
                watchlistItems: watchlistItems,
                viewModel: viewModel,
                showingAddPairs: $showingAddPairs,
                selectedItemForDetails: $selectedItemForDetails,
                onDeleteItems: deleteItems,
                onMoveItems: moveItems
            )
            .onAppear {
                viewModel.startStreaming(with: watchlistItems)
            }
            .onDisappear {
                viewModel.stopStreaming()
            }
            .onChange(of: watchlistItems) { _, newItems in
                viewModel.startStreaming(with: newItems)
            }
            .onChange(of: viewModel.connectionStatus) { _, newStatus in
                if newStatus == .disconnected {
                    showingAddPairs = false
                    selectedItemForDetails = nil
                }
            }
            .sheet(isPresented: $showingAddPairs) {
                AddPairsView(
                    availablePairs: viewModel.getAvailablePairs(excluding: watchlistItems),
                    connectionStatus: viewModel.connectionStatus
                ) { pairs in
                    viewModel.addPairs(pairs, to: watchlistItems, context: modelContext)
                }
            }
            .sheet(item: $selectedItemForDetails) { item in
                if let rate = viewModel.rates[item.pairString] {
                    PairDetailsView(item: item, rate: rate)
                }
            }
        } detail: {
            WatchlistDetailView()
        }
    }
    
    // MARK: - Private Methods
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            viewModel.deleteItems(at: offsets, from: watchlistItems, context: modelContext)
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            viewModel.moveItems(from: source, to: destination, in: watchlistItems)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WatchlistItem.self, inMemory: true)
}
