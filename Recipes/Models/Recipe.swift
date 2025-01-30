//
//  Recipe.swift
//  Recipes
//
//  Created by Dillon Teakell on 1/30/25.
//

import Foundation

// An array object of recipes
struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

struct Recipe: Codable, Hashable, Identifiable {
    let cuisine: String
    let name: String
    let photoUrlLarge: URL?
    let photoUrlSmall: URL?
    let sourceUrl: String?
    let id: String
    let youtubeUrl: String?
    
    // Coding keys to manually set the keys since .convertFromSnakeCase didn't work.
    enum CodingKeys: String, CodingKey {
        case cuisine
        case name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case id = "uuid"
        case youtubeUrl = "youtube_url"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
