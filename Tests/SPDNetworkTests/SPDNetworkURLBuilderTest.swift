//
//  File.swift
//  
//
//  Created by SAMBIT DASH on 02/08/20.
//

import XCTest
@testable import SPDNetwork

final class SPDNetworkURLBuilderTest: XCTestCase {
    private static let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=5a439649b46466212e07515d87737c1a&language=en-US&page=1"
    
    func testBuild() {
        let url = try! SPDNetworkURLBuilder("https://api.themoviedb.org/3/movie/popular")
            .addQueryItem(key: "api_key", value: "5a439649b46466212e07515d87737c1a")
            .addQueryItem(key: "language", value: "en-US")
            .addQueryItem(key: "page", value: 1)
            .build()
        XCTAssertEqual(url.absoluteString, SPDNetworkURLBuilderTest.urlString)
        
    }
    
    func testBuildWithEmptyBase() {
        let urlBuilder = SPDNetworkURLBuilder("")
        .addQueryItem(key: "api_key", value: "5a439649b46466212e07515d87737c1a")
        .addQueryItem(key: "language", value: "en-US")
        .addQueryItem(key: "page", value: 1)
        
        XCTAssertThrowsError(try urlBuilder.build()) { (error) in
            let urlError: SPDNetworkError = error as! SPDNetworkError
            XCTAssertEqual(urlError.errorDescription, SPDNetworkError.brokenURL.errorDescription)
            
        }
    }
}
