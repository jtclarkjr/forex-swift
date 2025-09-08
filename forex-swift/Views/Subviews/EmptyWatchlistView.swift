//
//  EmptyWatchlistView.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import SwiftUI

struct EmptyWatchlistView: View {
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Text("No Currency Pairs")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Add some currency pairs to start tracking live forex rates")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                onAddTapped()
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Currency Pairs")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyWatchlistView {
        print("Add tapped")
    }
}
