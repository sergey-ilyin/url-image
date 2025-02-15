//
//  TransientImage.swift
//  
//
//  Created by Dmytro Anokhin on 30/09/2020.
//

import SwiftUI
import Model


@available(macOS 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
public extension TransientImage {

    var image: Image {
        let orientation = Image.Orientation(cgOrientation)
        return Image(decorative: self.cgImage, scale: 1.0, orientation: orientation)
    }
}
