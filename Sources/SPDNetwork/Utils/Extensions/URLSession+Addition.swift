//
//  File.swift
//  
//
//  Created by SAMBIT DASH on 03/08/20.
//

import Foundation

extension URLRequest {
    mutating func authenticate(with auth: SPDNetworkAuth) {
        if !auth.value.isEmpty {
            self.addValue(auth.value, forHTTPHeaderField: SPDNetworkConstant.RequestHeader.authorization)
        }
    }
}
