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
    
    
    /// Request
    ///
    /// - Parameters:
    ///   - onResult: onResult callback
    public func makeRequest() throws -> AnyPublisher<Response, SPDNetworkError> {
        let session = URLSession(configuration: defaultSessionConfig)
        return session.dataTaskPublisher(for: try getURLRequest())
            .map { $0.data }
            .mapError { failure -> Error in
                
                return SPDNetworkError.apiError(reason: failure.localizedDescription)
            }
            .decode(type: Response.self, decoder: JSONDecoder())
            .catch { failure in
                Fail<Response, SPDNetworkError>(error: SPDNetworkError.apiError(reason: failure.localizedDescription))
            }
            .eraseToAnyPublisher()
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
