//
//  RecipeManagerTests.swift
//  RecipeManagerTests
//
//  Created by Dillon Teakell on 2/1/25.
//

import XCTest
@testable import Recipes

final class RecipeManagerTests: XCTestCase {
    
    var recipeManager: RecipeManager!
    var session: URLSession!

    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        recipeManager = RecipeManager(session: session)
    }
    
    // Test using empty data
    func testGetRecipesFromEmptyJSON() async throws {
        let emptyData = "[]".data(using: .utf8)!
        let emptyJSONEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
        
        MockURLProtocol.mockResponseData = emptyData
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: emptyJSONEndpoint)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        do {
            let recipes = try await recipeManager.getRecipes(
                from: emptyJSONEndpoint,
                isUsingCache: false
            )
            XCTAssertEqual(recipes.count, 0,"Expected empty array, but got: \(recipes.count) recipes")
        } catch {
            XCTFail("Experected no error, but got: \(error)")
        }
    }
    
    // Test using malformed data
    func testGetRecipesFromMalformedJSON() async throws {
        let malformedData = "{ invalid_json: true }".data(using: .utf8)!
        let malformedJSONEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
        
        MockURLProtocol.mockResponseData = malformedData
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: malformedJSONEndpoint)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        do {
            // Test fails if the request is successful
            _ = try await recipeManager.getRecipes(from: malformedJSONEndpoint, isUsingCache: false)
            XCTFail("Expected error for invalid data, but got success")
        } catch let error as RecipeManagerNetworkError {
            // Test succeeds if the invalid data error is thrown
            XCTAssertEqual(error, .invalidData, "Expected .invalidData error, but got \(error)")
        } catch {
            // Test fails if there is any other error
            XCTFail("Unexpected error: \(error)")
        }
    }
}
