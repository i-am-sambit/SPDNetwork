//
//  SPDNetworkConstant.swift
//  SPDNetwork
//
//  Created by SAMBIT DASH on 02/07/20.
//  Copyright © 2020 SAMBIT DASH. All rights reserved.
//

import Foundation

public enum SPDNetworkConstant {
    public enum RequestMethod: String {
        case get        = "GET"
        case post       = "POST"
        case put        = "PUT"
        case delete     = "DELETE"
    }
    
    internal enum RequestHeader {
        static let contentLength        = "Content-Length"
        static let authorization        = "Authorization"
        static let connection           = "Connection"
        static let host                 = "Host"
        static let proxyAuthenticate    = "Proxy-Authenticate"
        static let proxyAuthorization   = "Proxy-Authorization"
        static let wwwAuthenticate      = "WWW-Authenticate"
    }
}
