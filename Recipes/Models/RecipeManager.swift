//
//  RecipeManager.swift
//  Recipes
//
//  Created by Dillon Teakell on 1/30/25.
//

import Foundation


enum RecipeManagerNetworkError: Error {
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

final class RecipeManager {
    
    // Create file
    private let fileName = "recipes.json"
    
    // Create a session constant for testing purposes
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Function to get recipes from the URL
    func getRecipes(from endPoint: String = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json", isUsingCache: Bool = true) async throws -> [Recipe] {
        
        // Load recipes from file
        if isUsingCache, let loadedRecipes = loadRecipesFromFile(), !loadedRecipes.isEmpty {
            return loadedRecipes
        } else {
            print("No file found, loading from API")
        }
        
        // Convert the endpoint into a URL and handle errors
        guard let url = URL(string: endPoint) else {
            throw RecipeManagerNetworkError.invalidURL
        }
        
        // Get data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Convert the response into an HTTPURLResponse to get the status code
        guard let response = response as? HTTPURLResponse else {
            throw RecipeManagerNetworkError.unknown
        }
        
        switch response.statusCode {
        // Successful
        case 200:
            do {
                // Decode JSON
                let decoder = JSONDecoder()
                var recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
                
                // Manually fix JSON encoding
                for i in 0..<recipeResponse.recipes.count {
                     recipeResponse.recipes[i].name = recipeResponse.recipes[i].name
                    .replacingOccurrences(of: "Å›", with: "ś")
                    .replacingOccurrences(of: "Ã©", with: "é")
                }
                
                // If testing, do not save
                if isUsingCache {
                    saveRecipesToFile(data)
                }
                
                return recipeResponse.recipes
            }
            catch {
                throw RecipeManagerNetworkError.invalidData
            }
            
        // All network status codes
        case 400:
            throw RecipeManagerNetworkError.badRequest
        case 401:
            throw RecipeManagerNetworkError.unauthorized
        case 403:
            throw RecipeManagerNetworkError.forbidden
        case 404:
            throw RecipeManagerNetworkError.notFound
        case 408:
            throw RecipeManagerNetworkError.requestTimeout
        case 500:
            throw RecipeManagerNetworkError.internalServerError
        case 502:
            throw RecipeManagerNetworkError.badGateway
        case 503:
            throw RecipeManagerNetworkError.serviceUnavailable
        default:
            throw RecipeManagerNetworkError.unknown
        }
    }
    
    // Function to get file
    private func getFileURL() -> URL {
        // Create a new instance of fileManager
        let fileManager = FileManager.default
        
        // Get the file URLs from the user documents directory
        let fileURLs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        // Return the first URL
        let fileURL = fileURLs[0].appendingPathComponent(fileName)

        return fileURL
    }
    
    // Function to save data to the file
    private func saveRecipesToFile(_ data: Data) {
        let fileURL = getFileURL()
        
        // Save data to file
        do {
            try data.write(to: fileURL, options: .atomic)
        }
        catch {
            print("Unexpected error: \(error).")
        }
    }
    
    // Function to load recipes from file
    func loadRecipesFromFile() -> [Recipe]? {
        let fileURL = getFileURL()
        
        // Check if the file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        // Load data from file
        do {
            let data = try Data(contentsOf: fileURL)
            
            // If file exists but is empty, return nil
            guard !data.isEmpty else {
                return nil
            }
            
            let decoder = JSONDecoder()
            var recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
            
            // Manually fix JSON encoding error
            for i in 0..<recipeResponse.recipes.count {
                 recipeResponse.recipes[i].name = recipeResponse.recipes[i].name
                .replacingOccurrences(of: "Å›", with: "ś")
                .replacingOccurrences(of: "Ã©", with: "é")
            }
            
            return recipeResponse.recipes
        }
        catch {
            print("Error loading from file: \(error.localizedDescription).")
            return nil
        }
    }
    
    // Function to remove file (if needed)
    private func removeFile() {
        let fileManager = FileManager.default
        let fileURL = getFileURL()
        
        // Check if the file exists and remove it
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Could not remove file")
        }
    }
}
