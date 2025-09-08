//
//  ConnectionStatusBar.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import SwiftUI

struct ConnectionStatusBar: View {
    let status: ConnectionStatus
    let lastUpdated: Date?
    
    private var statusColor: Color {
        switch status {
        case .connected:
            return .green
        case .connecting:
            return .orange
        case .disconnected:
            return .red
        }
    }
    
    private var statusText: String {
        switch status {
        case .connected:
            if let lastUpdated = lastUpdated {
                return "Connected • \(formatTime(lastUpdated))"
            } else {
                return "Connected"
            }
        case .connecting:
            return "Connecting..."
        case .disconnected:
            return "Disconnected"
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private func formatTime(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 5 {
            return "just now"
        } else if interval < 60 {
            return "\(Int(interval))s ago"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

#Preview {
    VStack {
        ConnectionStatusBar(status: .connected, lastUpdated: Date())
        ConnectionStatusBar(status: .connecting, lastUpdated: nil)
        ConnectionStatusBar(status: .disconnected, lastUpdated: Date())
    }
}
