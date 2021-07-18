
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
public struct SPDAsyncWebImage: View {
    private var url: URL?
    private var placeHolder: Image?
    
    @ObservedObject var binder = SPDAsyncWebImageBinder()
    
    public init(url: URL?, placeHolder: Image? = nil) {
        self.url = url
        self.placeHolder = placeHolder
        self.binder.load(url: self.url)
    }
    
    public var body: some View {
        VStack {
            if binder.image != nil {
                Image(uiImage: binder.image!)
                    .renderingMode(.original)
                    .resizable()
            } else if binder.isLoading && !binder.isFinished {
                SPDActivityIndicatorView(isAnimating: Binding<Bool>(
                    get: { self.binder.isLoading && !self.binder.isFinished },
                    set: { _ in }), style: .large)
                    .foregroundColor(.secondary)
            } else {
                placeHolder
            }
        }
        .onAppear {  }
        .onDisappear {  }
    }
}

@available(OSX 10.15, *)
@available(iOS 13.0, *)
struct SPDAsyncWebImage_Previews: PreviewProvider {
    static var previews: some View {
        SPDAsyncWebImage(url: URL(string: "https://image.tmdb.org/t/p/original/cDbOrc2RtIA37nLm0CzVpFLrdaG.jpg")!)
    }
}
