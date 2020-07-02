SPDNetwork
==========

SPDNetwork is a pure Swift Library for networking. It also supports downloading and caching images from web. 

Installation
------------
Currently SPDNetwork supports Swift package manager. 

Installation with Swift Package Manager
----------------------------------------------
`
dependencies: [
    .package(url: "https://github.com/i-am-sambit/SPDNetwork", .upToNextMajor(from: "1.0.0"))
]
`


Usage
-------

Create URL
`
let url = try SPDNetworkURLBuilder("https://api.themoviedb.org/3/trending/movie/week")
    .addQueryItem(name: QueryConstants.Keys.kAPIKey, value: QueryConstants.Values.kAPIKey)
    .addQueryItem(name: QueryConstants.Keys.kLanguage, value: QueryConstants.Values.kLanguage)
    .addQueryItem(name: QueryConstants.Keys.kPage, value: page)
    .build()
    `

`
return try SPDNetworking<MoviesResponse>(url: url, method: .get).makeRequest()
    .eraseToAnyPublisher()
    `
