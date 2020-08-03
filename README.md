SPDNetwork
==========

SPDNetwork is a pure Swift Library for networking. It also supports downloading and caching images from web. 

Installation
------------
Currently SPDNetwork supports Swift package manager. `However, It is in development stage. It will be available soon`

Installation with Swift Package Manager
----------------------------------------------
```
dependencies: [
    .package(url: "https://github.com/i-am-sambit/SPDNetwork", .upToNextMajor(from: "1.0.0"))
]
```


Usage
=====

***

Create a datatask with combine framework

1. Create the URL with SPDNetworkURLBuilder

```
import SPDNetwork
import SPDNetworkCombine

let url = try? SPDNetworkURLBuilder("https://example.com")
        .addQueryItem(name: "Key", value: "Value")
        .build()
```

2. Make a **GET** request with SPDNetworking
```
do {
    let subscriber = try SPDCNetworking<YourResponseModel>(url: url, method: .get)
    .makeRequest()
    .sink(receiveCompletion: { (completionHandler) in
        switch completionHandler {
            
        case .finished:
            print("received succesfully...")
        case .failure(let error):
            print("error received : \(error.localizedDescription)")
        }
    }, receiveValue: { (response) in
        // Handle response here...
    })
} catch let error {
    print(error.localizedDescription)
}
```
> `YourResponseModel` should confirm `Decodable` protocol

3. Make a **POST** request with SPDNetworking

Create a request Model
```
struct YourRequestModel: Encodable {
    let username: String
    let password: String
}

```

Create an instance of request model and use that request model instance, while instantiating `SPDNetworking`
```
do {

    let request: YourRequestModel = YourRequestModel(username: "username", password: "password")
    
    let subscriber = try SPDCNetworking<MoviesResponse>(url: url, request: request, method: .post)
    .makeRequest()
    .sink(receiveCompletion: { (completionHandler) in
        switch completionHandler {
            
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
            // Handle error here
        }
    }, receiveValue: { (response) in
        // Handle response
    })
} catch let error {
    print(error.localizedDescription)
}
```
