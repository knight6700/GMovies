//  ImageCaching.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import UIKit

public protocol ImageCaching {
    func set(_ image: UIImage, for url: URL)
    func get(for url: URL) -> UIImage?
}
