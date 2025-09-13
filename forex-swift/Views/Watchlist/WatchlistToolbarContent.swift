//
//  WatchlistToolbarContent.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/13.
//

import SwiftUI

struct WatchlistToolbarContent: ToolbarContent {
    let watchlistItems: [WatchlistItem]
    let viewModel: WatchlistViewModel
    @Binding var showingAddPairs: Bool
    
    private var isAddButtonDisabled: Bool {
        viewModel.getAvailablePairs(excluding: watchlistItems).isEmpty || 
        viewModel.connectionStatus == .disconnected
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                if viewModel.connectionStatus != .disconnected {
                    showingAddPairs = true
                }
            } label: {
                Image(systemName: "plus")
            }
            .disabled(isAddButtonDisabled)
            .foregroundColor(isAddButtonDisabled ? .gray : .accentColor)
        }
        
        if !watchlistItems.isEmpty {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
    }
}

// Helper preview view to test toolbar content
struct WatchlistToolbarContentPreview: View {
    @State private var showingAddPairs = false
    
    var body: some View {
        NavigationView {
            Text("Preview Content")
                .toolbar {
                    WatchlistToolbarContent(
                        watchlistItems: [],
                        viewModel: WatchlistViewModel(),
                        showingAddPairs: $showingAddPairs
                    )
                }
        }
    }
}

#Preview {
    WatchlistToolbarContentPreview()
}