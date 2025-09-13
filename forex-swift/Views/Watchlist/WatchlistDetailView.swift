//
//  WatchlistDetailView.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/13.
//

import SwiftUI

struct WatchlistDetailView: View {
    var body: some View {
        ContentUnavailableView(
            "Select a Currency Pair",
            systemImage: "chart.line.uptrend.xyaxis",
            description: Text("Choose a pair from the watchlist to view detailed information")
        )
    }
}

#Preview {
    WatchlistDetailView()
}