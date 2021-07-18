import XCTest
@testable import SPDNetwork

final class SPDNetworkManagerTests: XCTestCase {
    var makeRequestExpectation: XCTestExpectation?
    var downloadRequestExpectation: XCTestExpectation?
    
    func testMakeRequestSucess() {
        makeRequestExpectation = self.expectation(description: "MakeRequest")
        
        let url: URL = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=5a439649b46466212e07515d87737c1a&language=en-US&page=1")!
        SPDNetworkManager(url: url).makeRequest { (result: Result<MoviesResponse, SPDNetworkError>) in
            switch result {
            
            case .success(let response):
                XCTAssertEqual(response.page, 1)
                self.makeRequestExpectation?.fulfill()
            case .failure(_):
                break
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testMakeRequestBadURL() {
        makeRequestExpectation = self.expectation(description: "MakeRequest")
        
        let url: URL = URL(string: "https://api.themoviedb.com/3/movie/popular?api_key=5a439649b46466212e07515d87737c1a")!
        SPDNetworkManager(url: url).makeRequest { (result: Result<MoviesResponse, SPDNetworkError>) in
            switch result {
            
            case .success(let response):
                XCTAssertEqual(response.page, 1)
            case .failure(let error):
                XCTAssertEqual(error.errorDescription, "The certificate for this server is invalid. You might be connecting to a server that is pretending to be “api.themoviedb.com” which could put your confidential information at risk.")
                self.makeRequestExpectation?.fulfill()
                break
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testMakeRequestWithNoAPIKey() {
        makeRequestExpectation = self.expectation(description: "MakeRequest")
        
        let url: URL = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1")!
        SPDNetworkManager(url: url).makeRequest { (result: Result<MoviesResponse, SPDNetworkError>) in
            switch result {
            
            case .success(let response):
                XCTAssertEqual(response.code, 7)
                self.makeRequestExpectation?.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testMakeRequestWithOauth() {
        let auth: SPDNetworkAuth = .oAuth(accessToken: "5a439649b46466212e07515d87737c1a")
        XCTAssertNotEqual(auth.value, "")
        
        makeRequestExpectation = self.expectation(description: "MakeRequest")
        
        let url: URL = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1")!
        SPDNetworkManager(url: url, auth: auth).makeRequest { (result: Result<MoviesResponse, SPDNetworkError>) in
            switch result {
            
            case .success(_): self.makeRequestExpectation?.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testMakeRequestWithNOauth() {
        let auth: SPDNetworkAuth = .noAuth
        XCTAssertEqual(auth.value, "")
    }
    
    func testMakeRequestWithBasicAuth() {
        let auth: SPDNetworkAuth = .basic(username: "username", password: "password")
        XCTAssertNotEqual(auth.value, "")
    }

    func testEncodable() {
        makeRequestExpectation = self.expectation(description: "MakeRequest")
        
        let url: URL = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1")!
        let request = DemoRequest()
        SPDNetworkManager(url: url, request: request, method: .post).makeRequest { (result: Result<MoviesResponse, SPDNetworkError>) in
            switch result {
            
            case .success(_): break
            case .failure(let error):
                XCTAssertEqual(error.errorDescription, "The data couldn’t be written because it isn’t in the correct format.")
                self.makeRequestExpectation?.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testDownload() {
        downloadRequestExpectation = self.expectation(description: "downloadRequestExpectation")
        
        let url: URL = URL(string: "https://image.tmdb.org/t/p/original/cDbOrc2RtIA37nLm0CzVpFLrdaG.jpg")!
        SPDNetworkManager<String>(url: url).downloadRequest(progressHandler: { (progress) in
            print("Download progress: \(progress)")
        }) { (result) in
            switch result {
                
            case .success(let localURL):
                break
            case .failure(let error):
                XCTAssertEqual(error.errorDescription, SPDNetworkError.unknown.errorDescription.lowercased())
                self.downloadRequestExpectation?.fulfill()
            }
        }
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }
}
