//
//  SPDNetworking.swift
//  SPDNetwork
//
//  Created by SAMBIT DASH on 25/10/19.
//  Copyright © 2019 SAMBIT DASH. All rights reserved.
//

import Foundation
import Combine

open class SPDNetworking<Response: Decodable>: NSObject {
    private var url: URL
    private var request: Encodable?
    private var method: SPDNetworkConstant.RequestMethod
    private var auth: SPDNetworkAuth
    
    private let imageCache: NSCache = NSCache<NSURL, NSData>()
    
    private var rechability = SPDNetworkReachability.shared
    
    
    /// This is a designated initializer.
    ///
    /// This will encapsulate four properties of SPDNetworking.
    /// - URL: You can construct a url with SPDNetworkURLBuilder or directly you can
    ///        create a url with your url string.
    ///
    /// - Request Data: Create your encodable model with required data. e.g.
    ///
    ///       struct RequestModel: Encodable {
    ///           let username: String
    ///           let password: String
    ///           // add your properties
    ///       }
    ///
    ///       let request = RequestModel(username: "some username", password: "password")
    ///
    ///   You can create your own model like above.
    ///
    /// - Authentication: SPDNetworking supports 2 types of Authentication.
    ///
    ///   1. .noAuth - This is default. There will not use any authentication method.
    ///   2. .basic - This will use basicAuth authentication method. You need to set username and password while using
    ///               this auth type
    ///
    ///          .basic(username: "some username", password: "some password")
    ///
    ///   3. .oAuth - This will use OAuth 2.0 authentication method. You need to set authentication token, while using
    ///               this auth type.
    ///
    ///          .oAuth(accessToken: "some access token")
    ///
    /// - Parameters:
    ///   - url: requested URL
    ///   - request: Set instance of your model. Your model should confirm to Encodable protocol.
    ///   - method: Set method. Default is get.
    ///   - auth: Set auth type.
    public init(url: URL,
         request: Encodable? = nil,
         method: SPDNetworkConstant.RequestMethod = .get,
         auth: SPDNetworkAuth = .noAuth) {
        self.url     = url
        self.request = request
        self.method  = method
        self.auth    = auth
    }
    
    private var defaultSessionConfig: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300.0
        config.timeoutIntervalForResource = 300.0
        config.allowsCellularAccess = true
        return config
    }
    
    private var downloadSessionConfig: URLSessionConfiguration {
        let config = URLSessionConfiguration.background(withIdentifier: "")
        return config
    }
    
    
    /// getURLRequest
    ///
    /// - Returns: URLRequest instance
    /// - Throws: error while enoding request
    private func getURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.authenticate(with: auth)
        
        if let request = request {
            urlRequest.httpBody = try request.convertToData()
        }
        
        return urlRequest
    }
    
    
    /// Invoke this method to fetch data from URL.
    ///
    /// This will use the url, requested data (if any), request method and
    /// authentication type, that you have passed, while initiating the SPDNetworking.
    ///
    /// By using url, it will create a URLRequest instance.
    ///
    /// It will create data from request model instance and
    /// attach it to URLRequest instance
    ///
    /// Also It will attach the request method to URLRequest instance.
    ///
    /// It will add the authentication value (if other than noAuth) to header
    ///
    ///
    /// - Returns: a Publisher with Response and SPDNetworkError
    public func makeRequest() -> AnyPublisher<Response, SPDNetworkError> {
        let session = URLSession(configuration: defaultSessionConfig)
        
        do {
            return session.dataTaskPublisher(for: try getURLRequest())
            .map { $0.data }
            .mapError { SPDNetworkError.apiError(reason: $0.localizedDescription) }
            .decode(type: Response.self, decoder: JSONDecoder())
            .catch { Fail<Response, SPDNetworkError>(error: SPDNetworkError.apiError(reason: $0.localizedDescription)) }
            .eraseToAnyPublisher()
            
        } catch let error {
            return Fail<Response, SPDNetworkError>(error: SPDNetworkError.apiError(reason: error.localizedDescription))
                .eraseToAnyPublisher()
        }
        
    }
    
    public func downloadImage(completionHandler: @escaping((Result<Data, Error>) -> Void)) {
        if let cachedData: Data = imageCache.object(forKey: self.url as NSURL) as Data? {
            completionHandler(.success(cachedData))
        }
        
        URLSession.shared.dataTask(with: url) { (data, httpResponse, error) in
            if let error = error {
                completionHandler(.failure(error))
            }
            
            if let data = data {
                if let url: NSURL = httpResponse?.url as NSURL? {
                    self.imageCache.setObject(data as NSData, forKey: url)
                }
                completionHandler(.success(data))
            } else {
                
            }
        }.resume()
    }
    
    
}

fileprivate extension Encodable {
    func convertToData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

private extension URLRequest {
    mutating func authenticate(with auth: SPDNetworkAuth) {
        if !auth.value.isEmpty {
            self.addValue(auth.value, forHTTPHeaderField: SPDNetworkConstant.RequestHeader.authorization)
        }
    }
}
