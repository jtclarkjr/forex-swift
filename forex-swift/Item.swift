//
//  Item.swift
//  forex-swift
//
//  Created by James Clark on 2025/09/08.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
