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
            VStack(spacing: 0) {
                // Connection Status Bar
                ConnectionStatusBar(status: viewModel.connectionStatus, lastUpdated: viewModel.lastUpdated)
                
                if watchlistItems.isEmpty {
                    EmptyWatchlistView {
                        showingAddPairs = true
                    }
                } else {
                    List {
                        ForEach(watchlistItems, id: \.id) { item in
                            WatchlistItemRow(
                                item: item,
                                rate: viewModel.rates[item.pairString],
                                onTap: {
                                    selectedItemForDetails = item
                                }
                            )
                        }
                        .onDelete(perform: deleteItems)
                        .onMove(perform: moveItems)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.refreshRates()
                    }
                }
            }
            .navigationTitle("Forex Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPairs = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.getAvailablePairs(excluding: watchlistItems).isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .disabled(watchlistItems.isEmpty)
                }
            }
            .onAppear {
                viewModel.startStreaming(with: watchlistItems)
            }
            .onDisappear {
                viewModel.stopStreaming()
            }
            .onChange(of: watchlistItems) { _, newItems in
                viewModel.startStreaming(with: newItems)
            }
            .sheet(isPresented: $showingAddPairs) {
                AddPairsView(availablePairs: viewModel.getAvailablePairs(excluding: watchlistItems)) { pairs in
                    viewModel.addPairs(pairs, to: watchlistItems, context: modelContext)
                }
            }
            .sheet(item: $selectedItemForDetails) { item in
                if let rate = viewModel.rates[item.pairString] {
                    PairDetailsView(item: item, rate: rate)
                }
            }
        } detail: {
            Text("Select a currency pair to view details")
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
