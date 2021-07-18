//
//  SPDNetworking.swift
//  SPDNetwork
//
//  Created by SAMBIT DASH on 25/10/19.
//  Copyright © 2019 SAMBIT DASH. All rights reserved.
//

import Foundation
import Combine

open class SPDNetworkManager<Response: Decodable>: NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    public typealias CompletionHandler = (Result<Response, SPDNetworkError>) -> Void
    public typealias ProgressHandler = ((Progress) -> Void)
    public typealias DownloadCompletionHandler = ((Result<String, SPDNetworkError>) -> Void)
    
    private var url: URL
    private var request: Encodable?
    private var method: SPDNetworkConstant.RequestMethod
    private var auth: SPDNetworkAuth
    
    private let imageCache: NSCache = NSCache<NSURL, NSData>()
    
    private var rechability = SPDNetworkReachability.shared
    
    private var downloadProgress: Progress = Progress()
    private var downloadProgressHandler: ProgressHandler?
    private var downloadCompletionHandler: DownloadCompletionHandler?
    
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
    
    final public var defaultSessionConfig: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300.0
        config.timeoutIntervalForResource = 300.0
        config.allowsCellularAccess = true
        config.urlCache = URLCache.shared
        if #available(OSX 10.13, *) {
            config.waitsForConnectivity = true
        }
        config.requestCachePolicy = .returnCacheDataElseLoad
        return config
    }
    
    func downloadSessionConfig(with identifier: String) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        return config
    }
    
    /// getURLRequest
    ///
    /// - Returns: URLRequest instance
    /// - Throws: error while enoding request
    final public func getURLRequest() throws -> URLRequest {
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
    /// - Parameter completionHandler: will be invoked, when response is received
    public func makeRequest(completionHandler: @escaping CompletionHandler) {
        do {
            let session = URLSession(configuration: defaultSessionConfig)
            session.dataTask(with: try getURLRequest()) { (data, urlResponse, error) in
                if let unwrappedError = error {
                    completionHandler(.failure(SPDNetworkError.apiError(reason: unwrappedError.localizedDescription)))
                } else if let data = data {
                    let result: Result<Response, SPDNetworkError> = data.convertToResponse()
                    completionHandler(result)
                }
            }.resume()
            session.finishTasksAndInvalidate()
            
        } catch let error {
            let encodingError: EncodingError = error as! EncodingError
            completionHandler(.failure(SPDNetworkError.apiError(reason: error.localizedDescription)))
        }
        
    }
    
    public func downloadRequest(progressHandler: @escaping ProgressHandler, completionHandler: @escaping DownloadCompletionHandler) {
        do {
            self.downloadCompletionHandler = completionHandler
            self.downloadProgressHandler = progressHandler
            
            let session = URLSession(configuration: downloadSessionConfig(with: url.absoluteString), delegate: self, delegateQueue: nil)
            session.downloadTask(with: try getURLRequest()).resume()
            session.finishTasksAndInvalidate()
        } catch let error {
            completionHandler(.failure(SPDNetworkError.apiError(reason: error.localizedDescription)))
        }
        
    }
    
    func downloadImage(completionHandler: @escaping((Result<Data, Error>) -> Void)) {
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
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let error = downloadTask.error {
            self.downloadCompletionHandler?(.failure(SPDNetworkError.apiError(reason: error.localizedDescription)))
        } else {
            self.downloadCompletionHandler?(.success(location.absoluteString))
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadProgress.totalUnitCount = totalBytesExpectedToWrite
        downloadProgress.completedUnitCount = totalBytesWritten
        self.downloadProgressHandler?(downloadProgress)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.downloadCompletionHandler?(.failure(SPDNetworkError.apiError(reason: error.localizedDescription)))
        }
    }
}

