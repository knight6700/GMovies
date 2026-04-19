//  CachedAsyncImage.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import Combine
import OSLog
import Utilities


private final class ImageLoader: ObservableObject {

    @Published var image: UIImage?

    private var cancellable: AnyCancellable?
    private let cache: any ImageCaching
    private let registry: any InFlightRegistering
    private let session: URLSession

    init(
        cache: any ImageCaching = ImageCache.shared,
        registry: any InFlightRegistering = InFlightRegistry.shared,
        session: URLSession = .imageLoading
    ) {
        self.cache = cache
        self.registry = registry
        self.session = session
    }

    func load(url: URL?) {
        guard let url else { return }

        if let cached = cache.get(for: url) {
            image = cached
            return
        }

        if let inFlight = registry.publisher(for: url) {
            cancellable = inFlight
                .receive(on: DispatchQueue.main)
                .sink { [weak self] img in
                    self?.cache.set(img, for: url)
                    self?.image = img
                }
            return
        }

        let subject = registry.register(url: url)

        cancellable = session.dataTaskPublisher(for: url)
            .tryMap { data, _ -> UIImage in
                guard let img = UIImage(data: data) else {
                    throw ImageDecodeError.decodeFailed(url)
                }
                return img
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.registry.complete(url: url)
                    case .failure:
                        self?.registry.cancel(url: url)
                    }
                    if case .failure(let error) = completion {
                        Logger.imageLoader.error("[ImageLoader] load failed for \(url): \(error)")
                    }
                },
                receiveValue: { [weak self] img in
                    self?.cache.set(img, for: url)
                    self?.image = img
                    subject.send(img)
                    subject.send(completion: .finished)
                }
            )
    }

    func cancel() {
        cancellable?.cancel()
    }
}

public struct CachedAsyncImage<Content: View, Placeholder: View>: View {

    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @StateObject private var loader: ImageLoader

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader())
    }

    init(
        url: URL?,
        cache: any ImageCaching,
        registry: any InFlightRegistering = InFlightRegistry.shared,
        session: URLSession = .imageLoading,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(cache: cache, registry: registry, session: session))
    }

    public var body: some View {
        Group {
            if let uiImage = loader.image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .onAppear { loader.load(url: url) }
        .onDisappear { loader.cancel() }
    }
}
