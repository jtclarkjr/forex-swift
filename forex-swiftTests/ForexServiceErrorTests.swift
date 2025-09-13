//
//  ForexServiceErrorTests.swift
//  forex-swiftTests
//
//  Created by James Clark on 2025/09/13.
//  Unit tests for ForexService error handling
//

import Testing
import Foundation
@testable import forex_swift

struct ForexServiceErrorTests {
    
    // MARK: - ForexServiceError Tests
    
    @Test("ForexServiceError provides correct error descriptions")
    func testErrorDescriptions() {
        let errors: [ForexServiceError] = [
            .invalidURL,
            .noData,
            .invalidResponse,
            .quotaExceeded,
            .serviceUnavailable,
            .connectionFailed,
            .unknown(NSError(domain: "TestDomain", code: 999, userInfo: [NSLocalizedDescriptionKey: "Custom error"]))
        ]
        
        let expectedDescriptions = [
            "Invalid URL",
            "No data received from forex service",
            "Invalid response format from forex service",
            "API quota exceeded. Please try again later.",
            "Forex service is temporarily unavailable. Please try again later.",
            "Unable to connect to forex service. Please check your internet connection.",
            "Custom error"
        ]
        
        for (index, error) in errors.enumerated() {
            #expect(error.errorDescription == expectedDescriptions[index])
        }
    }
    
    @Test("ForexServiceError conforms to LocalizedError")
    func testLocalizedErrorConformance() {
        let error: LocalizedError = ForexServiceError.invalidURL
        
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription == "Invalid URL")
    }
    
    @Test("Unknown error wraps underlying error correctly")
    func testUnknownErrorWrapping() {
        let underlyingError = NSError(
            domain: "NetworkError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Server internal error"]
        )
        
        let forexError = ForexServiceError.unknown(underlyingError)
        
        switch forexError {
        case .unknown(let wrappedError):
            #expect(wrappedError.localizedDescription == "Server internal error")
        default:
            #expect(Bool(false), "Expected unknown error case")
        }
    }
    
    @Test("All error cases can be instantiated")
    func testAllErrorCases() {
        let testError = NSError(domain: "Test", code: 1, userInfo: nil)
        
        let errors: [ForexServiceError] = [
            .invalidURL,
            .noData,
            .invalidResponse,
            .quotaExceeded,
            .serviceUnavailable,
            .connectionFailed,
            .unknown(testError)
        ]
        
        #expect(errors.count == 7)
        
        // Verify each error has a description
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }
    
    // MARK: - Error Case Matching Tests
    
    @Test("Error cases can be matched correctly")
    func testErrorCaseMatching() {
        let invalidURLError = ForexServiceError.invalidURL
        let quotaError = ForexServiceError.quotaExceeded
        let unknownError = ForexServiceError.unknown(NSError(domain: "Test", code: 1, userInfo: nil))
        
        switch invalidURLError {
        case .invalidURL:
            // Expected case
            break
        default:
            #expect(Bool(false), "Expected invalidURL case")
        }
        
        switch quotaError {
        case .quotaExceeded:
            // Expected case
            break
        default:
            #expect(Bool(false), "Expected quotaExceeded case")
        }
        
        switch unknownError {
        case .unknown(let error):
            #expect(error != nil)
        default:
            #expect(Bool(false), "Expected unknown case")
        }
    }
    
    // MARK: - Error Context Tests
    
    @Test("Service errors provide appropriate user feedback")
    func testUserFriendlyErrorMessages() {
        let userFacingErrors = [
            ForexServiceError.quotaExceeded.errorDescription,
            ForexServiceError.serviceUnavailable.errorDescription,
            ForexServiceError.connectionFailed.errorDescription
        ]
        
        // These errors should provide actionable guidance to users
        #expect(userFacingErrors[0]?.contains("try again later") == true)
        #expect(userFacingErrors[1]?.contains("temporarily unavailable") == true)
        #expect(userFacingErrors[2]?.contains("internet connection") == true)
    }
    
    @Test("Technical errors provide appropriate developer feedback") 
    func testDeveloperFriendlyErrorMessages() {
        let technicalErrors = [
            ForexServiceError.invalidURL.errorDescription,
            ForexServiceError.noData.errorDescription,
            ForexServiceError.invalidResponse.errorDescription
        ]
        
        // These errors should be clear for developers
        #expect(technicalErrors[0] == "Invalid URL")
        #expect(technicalErrors[1]?.contains("No data received") == true)
        #expect(technicalErrors[2]?.contains("Invalid response format") == true)
    }
}
