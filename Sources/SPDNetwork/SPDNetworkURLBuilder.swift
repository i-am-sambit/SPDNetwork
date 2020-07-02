//
//  SPDNetworkURLBuilder.swift
//  SPDNetwork
//
//  Created by SAMBIT DASH on 09/11/19.
//  Copyright © 2019 SAMBIT DASH. All rights reserved.
//

import Foundation

public final class SPDNetworkURLBuilder {
    private enum WebServiceConstats {
        static let kScheme          = "https"
        static let kHost            = "api.themoviedb.org"
        static let kImageHost       = "image.tmdb.org"
        static let kDatabaseVersion = "/3"
        static let kMovie           = "/movie"
        static let kTV              = "/tv"
        static let kImagePath       = "/t/p/w300_and_h300_bestv2"
    }
    
    private var components: URLComponents?
    private var baseURL: String = ""
    private lazy var posterPath: String = ""
    
    public init(_ baseUrl: String) {
        self.components = URLComponents(string: baseUrl)
    }
    
    public func addQueryItem<Element>(name: String, value: Element) -> SPDNetworkURLBuilder  {
        if self.components?.queryItems == nil {
            self.components?.queryItems = []
        }
        self.components?.queryItems?.append(URLQueryItem(name: name, value: "\(value)"))
        return self
    }
    
    public func build() throws -> URL {
        guard let url = self.components?.url else {
            throw SPDNetworkError.brokenURL
        }
        
        return url
    }
    
//    public func buildImageURL() throws -> URL {
//        self.components.scheme = WebServiceConstats.kScheme
//        self.components.host = WebServiceConstats.kImageHost
//        self.components.path = WebServiceConstats.kImagePath + self.posterPath
//
//        guard let url = self.components.url else {
//            throw SPDNetworkError.brokenURL
//        }
//
//        return url
//    }
}

