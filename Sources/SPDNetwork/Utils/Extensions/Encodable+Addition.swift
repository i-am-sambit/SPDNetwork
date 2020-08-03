//
//  File.swift
//  
//
//  Created by SAMBIT DASH on 03/08/20.
//

import Foundation

extension Encodable {
    func convertToData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
