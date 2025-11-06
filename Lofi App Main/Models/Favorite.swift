//
//  Favorite.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation

struct Favorite: Codable, Identifiable {
    let id: String
    let trackId: String
    let addedAt: Date

    init(trackId: String) {
        self.id = UUID().uuidString
        self.trackId = trackId
        self.addedAt = Date()
    }
}
