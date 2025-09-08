//
//  ForexTypes.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import Foundation

// Supported currencies based on React Native version
enum SupportedCurrency: String, CaseIterable, Codable {
    case USD = "USD"
    case JPY = "JPY"
    case EUR = "EUR"
    case GBP = "GBP"
    case AUD = "AUD"
    case CAD = "CAD"
    case CHF = "CHF"
    case CNY = "CNY"
}

// Supported currency pairs
enum SupportedPair: String, CaseIterable, Codable {
    case USDJPY = "USD/JPY"
    case EURUSD = "EUR/USD"
    case GBPUSD = "GBP/USD"
    case AUDUSD = "AUD/USD"
    case USDCAD = "USD/CAD"
    case USDCHF = "USD/CHF"
    case USDCNY = "USD/CNY"
    case EURJPY = "EUR/JPY"
    case GBPJPY = "GBP/JPY"
    
    var baseCurrency: SupportedCurrency {
        let components = self.rawValue.split(separator: "/")
        return SupportedCurrency(rawValue: String(components[0])) ?? .USD
    }
    
    var quoteCurrency: SupportedCurrency {
        let components = self.rawValue.split(separator: "/")
        return SupportedCurrency(rawValue: String(components[1])) ?? .JPY
    }
}

// Connection status for streaming
enum ConnectionStatus: String, Codable {
    case connected = "connected"
    case connecting = "connecting"
    case disconnected = "disconnected"
}

// Main forex rate structure matching React Native API
struct ForexRate: Codable, Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let bid: Double
    let ask: Double
    let price: Double
    let timeStamp: String
    
    enum CodingKeys: String, CodingKey {
        case from, to, bid, ask, price
        case timeStamp = "time_stamp"
    }
    
    var pair: String {
        return "\(from)/\(to)"
    }
    
    var spread: Double {
        return ask - bid
    }
    
    var spreadPercentage: Double {
        return (spread / price) * 100
    }
}

// API Response wrapper
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}
