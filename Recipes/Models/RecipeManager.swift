//
//  RecipeManager.swift
//  Recipes
//
//  Created by Dillon Teakell on 1/30/25.
//

import Foundation

enum RecipeManagerError: Error {
    case invalidURL
    case invalidData
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case requestTimeout
    case internalServerError
    case badGateway
    case serviceUnavailable
    case unknown
}

class RecipeManager {
    
    // Get a recipe
    func getRecipes() async throws -> [Recipe] {
        // Get endpoint
        let endpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
        
        // Convert the endpoint into a URL and handle errors
        guard let url = URL(string: endpoint) else {
            throw RecipeManagerError.invalidURL
        }
        
        // Get data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Convert the response into an HTTPURLResponse to get the status code
        guard let response = response as? HTTPURLResponse else {
            throw RecipeManagerError.unknown
        }
        
        switch response.statusCode {
        // Successful
        case 200:
            do {
                // Decode JSON
                let decoder = JSONDecoder()
                let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
                return recipeResponse.recipes
            }
            catch {
                throw RecipeManagerError.invalidData
            }
            
        // All network status codes
        case 400:
            throw RecipeManagerError.badRequest
        case 401:
            throw RecipeManagerError.unauthorized
        case 403:
            throw RecipeManagerError.forbidden
        case 404:
            throw RecipeManagerError.notFound
        case 408:
            throw RecipeManagerError.requestTimeout
        case 500:
            throw RecipeManagerError.internalServerError
        case 502:
            throw RecipeManagerError.badGateway
        case 503:
            throw RecipeManagerError.serviceUnavailable
        default:
            throw RecipeManagerError.unknown
        }
    }
}
