//
//  AsyncImageBinder.swift
//  MoviesApp
//
//  Created by SAMBIT DASH on 24/06/20.
//  Copyright © 2020 SAMBIT DASH. All rights reserved.
//

import Foundation
import Combine
#if os(iOS)
import UIKit
#endif

@available(OSX 10.15, *)
@available(iOS 13.0, *)
class SPDAsyncWebImageBinder: ObservableObject {
    private var subscription: AnyCancellable?
    
    private var cache = AsyncWebImageCache.shared
    
    #if os(iOS)
    @Published private(set) var image: UIImage?
    #else
    @Published private(set) var image: NSImage?
    #endif
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isFinished: Bool = false
    @Published private(set) var isCanceled: Bool = false
    
    func load(url: URL) {
        #if os(iOS)
        if let image: UIImage = cache[url.absoluteString] {
            self.image = image
            return
        }
        #else
        if let image: NSImage = cache[url.absoluteString] {
            self.image = image
            return
        }
        #endif
        
        subscription = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { _ in self.isLoading = true },
                          receiveOutput: { self.cache[url.absoluteString] = $0 },
                          receiveCompletion: { completion in self.isFinished = true },
                          receiveCancel: { self.isCanceled = true },
                          receiveRequest: { demand in })
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        subscription?.cancel()
    }
}


