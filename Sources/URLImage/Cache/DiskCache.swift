//
//  DiskCache.swift
//  
//
//  Created by Dmytro Anokhin on 02/10/2020.
//

import Foundation
import Combine
import FileIndex


final class DiskCache {

    let fileIndex: FileIndex

    init(fileIndex: FileIndex) {
        self.fileIndex = fileIndex
    }

    convenience init() {
        let fileIndexConfiguration = FileIndex.Configuration(name: "URLImage",
                                                             filesDirectoryName: "images",
                                                             baseDirectoryName: "URLImage")
        let fileIndex = FileIndex(configuration: fileIndexConfiguration)
        self.init(fileIndex: fileIndex)
    }

    func getImage(withIdentifier identifier: String?,
                  orURL url: URL,
                  _ completion: @escaping (_ result: Result<TransientImage?, Swift.Error>) -> Void
    ) {
        databaseQueue.async { [weak self] in
            guard let self = self else { return }

            guard let file = self.getFile(withIdentifier: identifier, orURL: url) else {
                completion(.success(nil))
                return
            }

            self.decodeQueue.async { [weak self] in
                guard let self = self else { return }

                do {
                    let location = self.fileIndex.location(of: file)
                    let transientImage = try TransientImage.decode(location)
                    completion(.success(transientImage))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
    }

    func getImagePublisher(withIdentifier identifier: String?, orURL url: URL) -> AnyPublisher<TransientImage?, Swift.Error> {
        return Future<TransientImage?, Swift.Error> { [weak self] promise in
            guard let self = self else {
                return
            }

            self.getImage(withIdentifier: identifier, orURL: url) {
                promise($0)
            }
        }.eraseToAnyPublisher()
    }

    func cacheImageData(_ data: Data, url: URL, identifier: String?, fileName: String?, fileExtension: String?, expireAfter expiryInterval: TimeInterval?) {
        _ = try? fileIndex.write(data,
                                 originalURL: url,
                                 identifier: identifier,
                                 fileName: fileName,
                                 fileExtension: fileExtension,
                                 expireAfter: expiryInterval)
    }

    func cacheImageFile(at location: URL, url: URL, identifier: String?, fileName: String?, fileExtension: String?, expireAfter expiryInterval: TimeInterval?) {
    }

    // MARK: - Cleanup

    func cleanup() {
        fileIndex.deleteExpired()
    }

    func delete(withIdentifier identifier: String?, orURL url: URL?) {
        databaseQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            guard let file = self.getFile(withIdentifier: identifier, orURL: url) else {
                return
            }

            self.utilityQueue.async { [weak self] in
                guard let self = self else {
                    return
                }

                self.fileIndex.delete(file)
            }
        }
    }

    // MARK: - Path

    func filePath(forFileName fileName: String, fileExtension: String?) -> String {
        var fileURL = fileIndex.configuration.filesDirectoryURL.appendingPathComponent(fileName)

        if let fileExtension = fileExtension {
            fileURL.appendPathExtension(fileExtension)
        }

        return fileURL.path
    }

    // MARK: - Private

    private let databaseQueue = DispatchQueue(label: "URLImage.DiskCache.databaseQueue", attributes: .concurrent)
    private let decodeQueue = DispatchQueue(label: "URLImage.DiskCache.decodeQueue", attributes: .concurrent)
    private let utilityQueue = DispatchQueue(label: "URLImage.DiskCache.utilityQueue", qos: .utility, attributes: .concurrent)

    private func getFile(withIdentifier identifier: String?, orURL url: URL?) -> File? {
        if let identifier = identifier {
            return fileIndex.get(identifier).first
        }
        else if let url = url {
            return fileIndex.get(url).first
        }
        else {
            return nil
        }
    }
}
