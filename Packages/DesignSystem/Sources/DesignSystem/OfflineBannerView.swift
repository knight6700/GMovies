//  OfflineBannerView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI

public struct OfflineBannerView: View {

    public init() {} // Required for public access across modules

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "wifi.slash")
                .font(DSFont.bannerLabel)
            Text("Offline — showing cached content")
                .font(DSFont.bannerLabel)
        }
        .foregroundStyle(DSColor.onWarning)
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.sm)
        .background(DSColor.warning)
    }
}
