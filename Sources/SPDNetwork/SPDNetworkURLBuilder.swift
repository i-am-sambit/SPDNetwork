//
//  URLBuilder.swift
//  MoviesApp
//
//  Created by SAMBIT DASH on 09/11/19.
//  Copyright © 2019 SAMBIT DASH. All rights reserved.
//

import Foundation

open class SPDNetworkURLBuilder {
    private enum WebServiceConstats {
        static let kScheme          = "https"
        static let kHost            = "api.themoviedb.org"
        static let kImageHost       = "image.tmdb.org"
        static let kDatabaseVersion = "/3"
        static let kMovie           = "/movie"
        static let kTV              = "/tv"
        static let kImagePath       = "/t/p/w300_and_h300_bestv2"
    }
    
    private lazy var components: URLComponents = URLComponents()
    private lazy var operation:  String = ""
    private lazy var mediaId:    String = ""
    private lazy var posterPath: String = ""
    
    public init() {
        
    }
    
    open func set(operation: ServiceOperation) -> SPDNetworkURLBuilder {
        self.operation = operation.value
        return self
    }
    
    open func set(poster path: String) -> SPDNetworkURLBuilder {
        self.posterPath = path
        return self
    }
    
    open func addQueryItem<Element>(name: String, value: Element) -> SPDNetworkURLBuilder  {
        if self.components.queryItems == nil {
            self.components.queryItems = []
        }
        self.components.queryItems?.append(URLQueryItem(name: name, value: "\(value)"))
        return self
    }
    
    open func build() throws -> URL {
        self.components.scheme = WebServiceConstats.kScheme
        self.components.host = WebServiceConstats.kHost
        self.components.path = WebServiceConstats.kDatabaseVersion + self.operation
        
        guard let url = self.components.url else {
            throw SPDNetworkError.brokenURL
        }
        
        return url
    }
    
    open func buildImageURL() throws -> URL {
        self.components.scheme = WebServiceConstats.kScheme
        self.components.host = WebServiceConstats.kImageHost
        self.components.path = WebServiceConstats.kImagePath + self.posterPath
        
        guard let url = self.components.url else {
            throw SPDNetworkError.brokenURL
        }
        
        return url
    }
}

extension SPDNetworkURLBuilder {
    public enum ServiceOperation {
        case trending(timeWindow: Trending)
        case nowPlaying
        case popular
        case upcoming
        case topRated
        case details(media: Media, movieId: String)
        case credits(media: Media, movieId: String)
        case creditDetails(creditId: String)
        case similar(media: Media, movieId: String)
        case search(media: Media)
        
        var value: String {
            switch self {
                
            case .trending(timeWindow: let timeWindow):
                switch timeWindow {
                    
                case .day:
                    return "/trending/movie/day"
                case .week:
                    return "/trending/movie/week"
                }
            case .nowPlaying:
                return "/movie/now_playing"
            case .popular:
                return "/movie/popular"
            case .upcoming:
                return "/movie/upcoming"
            case .topRated:
                return "/movie/top_rated"
            case .details(media: let media, movieId: let mediaId):
                switch media {
                    
                case .movie:
                    return "/movie/\(mediaId)"
                case .tv:
                    return "/tv/\(mediaId)"
                }
                
            case .credits(media: let media, movieId: let mediaId):
                switch media {
                    
                case .movie:
                    return "/movie/\(mediaId)/credits"
                case .tv:
                    return "/tv/\(mediaId)/credits"
                }
            case .creditDetails(creditId: let creditID):
                return "/credit/" + creditID
            case .similar(media: let media, movieId: let mediaId):
                switch media {
                    
                case .movie:
                    return "/movie/\(mediaId)/similar"
                case .tv:
                    return "/tv/\(mediaId)/similar"
                }
            case .search(media: let media):
                return "/search" + media.rawValue
            }
        }
        
    }
    
    public enum Trending: String {
        case day    = "/day"
        case week   = "/week"
    }
    
    public enum Media: String {
        case movie = "/movie"
        case tv = "/tv"
    }
}
