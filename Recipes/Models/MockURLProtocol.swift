//
//  MockURLProtocol.swift
//  Recipes
//
//  Created by Dillon Teakell on 2/1/25.
//

import Foundation

// Creates a mock protocol for testing purposes
class MockURLProtocol: URLProtocol {
    
    // Holds mock JSON data, HTTP response, and error
    static var mockResponseData: Data?
    static var mockResponse: HTTPURLResponse?
    static var mockError: Error?
    
    // Intercepts all requests
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    // Ensures requests are consistent
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            
            // Doesn't store the response
            if let response = MockURLProtocol.mockResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = MockURLProtocol.mockResponseData {
                client?.urlProtocol(self, didLoad: data)
            }
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    
}
