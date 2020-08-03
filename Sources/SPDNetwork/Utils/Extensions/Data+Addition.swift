//
//  File.swift
//  
//
//  Created by SAMBIT DASH on 03/08/20.
//

import Foundation

extension Data {
    func convertToResponse<Response: Decodable>() -> Result<Response, SPDNetworkError> {
        do {
            let response = try JSONDecoder().decode(Response.self, from: self)
            return .success(response)
        } catch let error {
            return .failure(SPDNetworkError.apiError(reason: error.localizedDescription))
        }
    }
}
