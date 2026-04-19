//  ImagePrefetcher.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import UIKit
import Combine
import OSLog
import Utilities


enum ImageDecodeError: Error {
    case decodeFailed(URL)
}

public protocol InFlightRegistering {
    func publisher(for url: URL) -> AnyPublisher<UIImage, Never>?
    func register(url: URL) -> PassthroughSubject<UIImage, Never>
    func complete(url: URL)
    func cancel(url: URL)
}

public final class InFlightRegistry: InFlightRegistering {

    public static let shared = InFlightRegistry()

    private var subjects: [URL: PassthroughSubject<UIImage, Never>] = [:]
    private let lock = NSLock()

    public init() {} // Required for public access across modules

    public func publisher(for url: URL) -> AnyPublisher<UIImage, Never>? {
        lock.lock(); defer { lock.unlock() }
        return subjects[url]?.eraseToAnyPublisher()
    }

    public func register(url: URL) -> PassthroughSubject<UIImage, Never> {
        lock.lock(); defer { lock.unlock() }
        let subject = PassthroughSubject<UIImage, Never>()
        subjects[url] = subject
        return subject
    }

    public func complete(url: URL) {
        lock.lock(); defer { lock.unlock() }
        subjects.removeValue(forKey: url)
    }

    public func cancel(url: URL) {
        lock.lock()
        let subject = subjects.removeValue(forKey: url)
        lock.unlock()
        subject?.send(completion: .finished)
    }
}

extension URLSession {
    public static let imageLoading: URLSession = {
        let config = URLSessionConfiguration.default
        config.networkServiceType = .responsiveData
        config.httpMaximumConnectionsPerHost = 6
        config.timeoutIntervalForRequest = 15
        return URLSession(configuration: config)
    }()

    public static let imagePrefetch: URLSession = {
        let config = URLSessionConfiguration.default
        config.networkServiceType = .background
        config.httpMaximumConnectionsPerHost = 2
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()
}

public final class ImagePrefetcher: ImagePrefetching {

    private var cancellables: [URL: AnyCancellable] = [:]
    private let cancellablesLock = NSLock()
    private let cache: any ImageCaching
    private let registry: any InFlightRegistering
    private let session: URLSession

    public init(
        cache: any ImageCaching,
        registry: any InFlightRegistering,
        session: URLSession
    ) {
        self.cache = cache
        self.registry = registry
        self.session = session
    }

    public func prefetch(urls: [URL]) {
        for url in urls {
            guard cache.get(for: url) == nil else { continue }
            guard !isTracked(url) else { continue }
            if let inFlight = registry.publisher(for: url) {
                storeCancellable(
                    inFlight.sink { [weak self] image in
                        self?.cache.set(image, for: url)
                        self?.removeCancellable(for: url)
                    },
                    for: url
                )
                continue
            }

            startPrefetch(for: url)
        }
    }

    public func cancelPrefetch(urls: [URL]) {
        var cancellablesToCancel: [AnyCancellable] = []
        cancellablesLock.lock()
        for url in urls {
            if let cancellable = cancellables.removeValue(forKey: url) {
                cancellablesToCancel.append(cancellable)
            }
        }
        cancellablesLock.unlock()
        cancellablesToCancel.forEach { $0.cancel() }
        urls.forEach { registry.cancel(url: $0) }
    }

    private func isTracked(_ url: URL) -> Bool {
        cancellablesLock.lock()
        let isTracked = cancellables[url] != nil
        cancellablesLock.unlock()
        return isTracked
    }

    private func startPrefetch(for url: URL) {
        let subject = registry.register(url: url)
        let cancellable = session.dataTaskPublisher(for: url)
            .tryMap { data, _ -> UIImage in
                guard let image = UIImage(data: data) else {
                    throw ImageDecodeError.decodeFailed(url)
                }
                return image
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.handleCompletion(completion, for: url)
                },
                receiveValue: { [weak self] image in
                    self?.cache.set(image, for: url)
                    subject.send(image)
                    subject.send(completion: .finished)
                }
            )
        storeCancellable(cancellable, for: url)
    }

    private func handleCompletion(
        _ completion: Subscribers.Completion<Error>,
        for url: URL
    ) {
        switch completion {
        case .finished:
            registry.complete(url: url)
        case .failure:
            registry.cancel(url: url)
        }
        removeCancellable(for: url)
        if case .failure(let error) = completion {
            Logger.imagePrefetcher.error("[ImagePrefetcher] prefetch failed for \(url): \(error)")
        }
    }

    private func storeCancellable(_ cancellable: AnyCancellable, for url: URL) {
        cancellablesLock.lock()
        cancellables[url] = cancellable
        cancellablesLock.unlock()
    }

    private func removeCancellable(for url: URL) {
        cancellablesLock.lock()
        cancellables.removeValue(forKey: url)
        cancellablesLock.unlock()
    }
}
