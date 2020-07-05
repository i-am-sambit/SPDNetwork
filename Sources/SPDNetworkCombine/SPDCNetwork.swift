//
//  SPDNetworkCombine.swift
//  SPDNetwork
//
//  Created by SAMBIT DASH on 03/07/20.
//  Copyright © 2020 SAMBIT DASH. All rights reserved.
//

import Foundation
import SPDNetwork
import Combine

@available(iOS 13.0, *)
public class SPDCNetwork<Response: Decodable>: SPDNetwork<Response> {
    
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
    public override init(url: URL,
         request: Encodable? = nil,
         method: SPDNetworkConstant.RequestMethod = .get,
         auth: SPDNetworkAuth = .noAuth) {
        super.init(url: url, request: request, method: method, auth: auth)
    }
    
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
}
