//
//  SPDNetworkAuth.swift
//  MoviesApp
//
//  Created by SAMBIT DASH on 01/07/20.
//  Copyright © 2020 SAMBIT DASH. All rights reserved.
//

import Foundation

public enum SPDNetworkAuth {
    case noAuth
    case basic(username: String, password: String)
    case oAuth(accessToken: String)
    
    var value: String {
        switch self {
            
        case .noAuth:
            break
        case .basic(username: let username, password: let password):
            let credential = "\(username):\(password)"
            guard let credentialData = credential.data(using: .utf8) else { return "" }
            let encodedCredential = credentialData.base64EncodedString(options: .endLineWithLineFeed)
            return "Basic \(encodedCredential)"
        case .oAuth(accessToken: let accessToken):
            return "Bearer \(accessToken)"
        }
        
        return ""
    }
}
