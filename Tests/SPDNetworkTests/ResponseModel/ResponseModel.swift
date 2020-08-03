//
//  File.swift
//  
//
//  Created by SAMBIT DASH on 03/08/20.
//

import Foundation

class BaseMoviesResponse: Decodable {
    let code: Int
    let message: String
    let isSuccess: Bool
    let page: Int
    let totalResults: Int
    let totalPages: Int
    
    private enum CodingKeys: String, CodingKey {
        case code         = "status_code"
        case message      = "status_message"
        case isSuccess    = "success"
        case page         = "page"
        case totalResults = "total_results"
        case totalPages   = "total_pages"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decodeIfPresent(Int.self, forKey: .code) ?? 0
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        isSuccess = try container.decodeIfPresent(Bool.self, forKey: .isSuccess) ?? true
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 0
        totalResults = try container.decodeIfPresent(Int.self, forKey: .totalResults) ?? 0
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages) ?? 0
    }
}

class MoviesResponse: BaseMoviesResponse {
    let results: [Movie]
    
    private enum CodingKeys: String, CodingKey {
        case results = "results"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decodeIfPresent([Movie].self, forKey: .results) ?? []
        
        try super.init(from: decoder)
    }
}

struct Movie: Hashable, Decodable {
    var id:          Int
    var name:        String
    var overview:    String
    var poster:      String
    var releaseDate: String
    var rating:      Double
    var popularity:  Int
    
    private enum CodingKeys: String, CodingKey {
        case id          = "id"
        case name        = "title"
        case overview    = "overview"
        case poster      = "poster_path"
        case releaseDate = "release_date"
        case rating      = "vote_average"
        case popularity  = "popularity"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
        poster = try container.decodeIfPresent(String.self, forKey: .poster) ?? ""
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? ""
        rating = try container.decode(Double.self, forKey: .rating)
        popularity = Int(try container.decode(Double.self, forKey: .popularity))
    }
    
    init(id: Int, name: String, overview: String, poster: String, releaseDate: String, rating: Double, popularity: Int) {
        self.id = id
        self.name = name
        self.overview = name
        self.poster = name
        self.releaseDate = name
        self.rating = rating
        self.popularity = popularity
    }
}
