//
//  EnvironmentValues+URLImage.swift
//  
//
//  Created by Dmytro Anokhin on 12/02/2021.
//

import SwiftUI


@available(macOS 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
private struct URLImageServiceEnvironmentKey: EnvironmentKey {

    static let defaultValue: URLImageService = URLImageService()
}


@available(macOS 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
private struct URLImageOptionsEnvironmentKey: EnvironmentKey {

    static let defaultValue: URLImageOptions = URLImageOptions()
}


@available(macOS 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
public extension EnvironmentValues {

    /// Service used by instances of the `URLImage` view
    var urlImageService: URLImageService {
        get {
            self[URLImageServiceEnvironmentKey.self]
        }

        set {
            self[URLImageServiceEnvironmentKey.self] = newValue
        }
    }

    /// Options object used by instances of the `URLImage` view
    var urlImageOptions: URLImageOptions {
        get {
            self[URLImageOptionsEnvironmentKey.self]
        }

        set {
            self[URLImageOptionsEnvironmentKey.self] = newValue
        }
    }
}
