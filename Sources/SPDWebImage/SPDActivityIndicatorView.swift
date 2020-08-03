//
//  File.swift
//  
//
//  Created by SAMBIT DASH on 02/07/20.
//

import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
struct SPDActivityIndicatorView: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<SPDActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<SPDActivityIndicatorView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
