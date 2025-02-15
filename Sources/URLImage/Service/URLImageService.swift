//
//  URLImageService.swift
//  
//
//  Created by Dmytro Anokhin on 25/08/2020.
//

import Foundation
import CoreGraphics
import Combine
import Model
import DownloadManager


@available(macOS 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
public class URLImageService {

    public init(fileStore: URLImageFileStoreType? = nil, inMemoryStore: URLImageInMemoryStoreType? = nil) {
        self.fileStore = fileStore
        self.inMemoryStore = inMemoryStore
    }

    public let fileStore: URLImageFileStoreType?

    public let inMemoryStore: URLImageInMemoryStoreType?

    // MARK: - Internal

    let downloadManager = DownloadManager()
}
