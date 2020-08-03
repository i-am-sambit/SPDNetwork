//
//  SPDNetworkError.swift
//  SPDNetwork
//
//  Created by SAMBIT DASH on 01/07/20.
//  Copyright © 2020 SAMBIT DASH. All rights reserved.
//

import Foundation

public enum SPDNetworkError: Error, LocalizedError, Equatable {
    case unknown
    case brokenURL
    case apiError(reason: String)

    public var errorDescription: String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .brokenURL:
            return "URL is broken"
        case .apiError(let reason):
            return reason
        }
    }
}
