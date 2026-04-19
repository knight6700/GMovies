//  ImageCache.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import UIKit
import OSLog
import Utilities


public protocol ClockProviding: Sendable {
    func now() -> Date
}

public struct SystemClock: ClockProviding {
    public init() {}
    public func now() -> Date { Date() }
}

public final class ImageCache: ImageCaching {

    public static let shared = ImageCache()

    private let memory: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()

    private let diskDirectory: URL
    private let clock: any ClockProviding
    private let diskQueue = DispatchQueue(
        label: "com.gmovies.imagecache.disk",
        qos: .utility,
        attributes: .concurrent
    )

    private static let diskTTL: TimeInterval  = 7 * 24 * 3600
    private static let diskMaxBytes: Int      = 200 * 1024 * 1024
    private static let evictEveryNWrites: Int = 50

    private var diskWriteCount = 0

    public init(diskDirectory: URL? = nil, clock: any ClockProviding = SystemClock()) {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let defaultDir = caches.appendingPathComponent("GMovies/ImageCache", isDirectory: true)
        self.diskDirectory = diskDirectory ?? defaultDir
        self.clock = clock
        try? FileManager.default.createDirectory(at: self.diskDirectory, withIntermediateDirectories: true)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearMemory),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    public func set(_ image: UIImage, for url: URL) {
        let key = diskKey(for: url)
        let cost = image.jpegData(compressionQuality: 1)?.count ?? 0
        memory.setObject(image, forKey: key as NSString, cost: cost)

        diskQueue.async(flags: .barrier) { [weak self] in
            self?.writeToDisk(image, key: key)
        }
    }

    public func get(for url: URL) -> UIImage? {
        let key = diskKey(for: url)
        if let hit = memory.object(forKey: key as NSString) { return hit }
        guard let image = readFromDisk(key: key) else { return nil }
        memory.setObject(image, forKey: key as NSString, cost: 0)
        return image
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc public func clearMemory() {
        memory.removeAllObjects()
    }

    public func clearDisk() {
        diskQueue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            try? FileManager.default.removeItem(at: diskDirectory)
            try? FileManager.default.createDirectory(at: diskDirectory, withIntermediateDirectories: true)
        }
    }

    private func diskKey(for url: URL) -> String {
        url.path.replacingOccurrences(of: "/", with: "_")
    }

    private func fileURL(for key: String) -> URL {
        diskDirectory.appendingPathComponent(key)
    }

    private func writeToDisk(_ image: UIImage, key: String) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        do {
            try data.write(to: fileURL(for: key), options: .atomic)
        } catch {
            Logger.imageCache.error("[ImageCache] disk write failed for \(key): \(error)")
        }

        diskWriteCount += 1
        if diskWriteCount.isMultiple(of: Self.evictEveryNWrites) {
            evictExpiredAndOversized()
        }
    }

    private func readFromDisk(key: String) -> UIImage? {
        let file = fileURL(for: key)
        guard
            let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
            let modified = attrs[.modificationDate] as? Date,
            clock.now().timeIntervalSince(modified) < Self.diskTTL,
            let data = try? Data(contentsOf: file),
            let image = UIImage(data: data)
        else { return nil }
        return image
    }

    private func evictExpiredAndOversized() {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(
            at: diskDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else { return }

        var infos: [(url: URL, date: Date, size: Int)] = [] // swiftlint:disable:this large_tuple
        var totalBytes = 0

        for file in files {
            let res = try? file.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            let size = res?.fileSize ?? 0
            let date = res?.contentModificationDate ?? .distantPast

            if clock.now().timeIntervalSince(date) >= Self.diskTTL {
                try? fm.removeItem(at: file)
            } else {
                totalBytes += size
                infos.append((file, date, size))
            }
        }

        guard totalBytes > Self.diskMaxBytes else { return }

        for info in infos.sorted(by: { $0.date < $1.date }) {
            guard totalBytes > Self.diskMaxBytes else { break }
            try? fm.removeItem(at: info.url)
            totalBytes -= info.size
        }
    }
}
