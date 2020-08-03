//
//  File.swift
//  
//
//  Created by SAMBIT DASH on 02/07/20.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import Foundation

class AsyncWebImageCache {
    static let shared = AsyncWebImageCache()
    
    #if os(iOS)
    private var cache: NSCache = NSCache<NSString, UIImage>()
    #else
    private var cache: NSCache = NSCache<NSString, NSImage>()
    #endif
    
    #if os(iOS)
    subscript(key: String) -> UIImage? {
        get { cache.object(forKey: key as NSString) }
        set(image) { image == nil ? self.cache.removeObject(forKey: (key as NSString)) : self.cache.setObject(image!, forKey: (key as NSString)) }
    }
    #else
    subscript(key: String) -> NSImage? {
        get { cache.object(forKey: key as NSString) }
        set(image) { image == nil ? self.cache.removeObject(forKey: (key as NSString)) : self.cache.setObject(image!, forKey: (key as NSString)) }
    }
    #endif
    
}
