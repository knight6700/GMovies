//  AppSplashView.swift
//  GMovies
//
//  Created by Mahmoud Fares on 2026.
//  Copyright © 2026 Mahmoud Fares. All rights reserved.

import SwiftUI
import DesignSystem

struct AppSplashView: View {

    @State private var isAnimatedIn = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DSColor.background,
                    DSColor.surface,
                    DSColor.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ambientGlow(
                color: DSColor.accent.opacity(0.22),
                size: 260,
                x: 120,
                y: -220
            )

            ambientGlow(
                color: DSColor.warning.opacity(0.16),
                size: 220,
                x: -130,
                y: 240
            )

            VStack(spacing: DSSpacing.xxl) {
                brandMark
                brandText
            }
            .padding(.horizontal, DSSpacing.xxl)
        }
        .task {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                isAnimatedIn = true
            }
        }
    }

    private var brandMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DSColor.accent,
                            DSColor.primary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 104, height: 104)
                .shadow(color: DSColor.accent.opacity(0.25), radius: 24, y: 16)

            Image(systemName: "film.stack.fill")
                .font(DSFont.splashMark)
                .foregroundStyle(DSColor.background)
        }
        .scaleEffect(isAnimatedIn ? 1 : 0.88)
        .rotationEffect(.degrees(isAnimatedIn ? 0 : -8))
        .offset(y: isAnimatedIn ? 0 : 8)
    }

    private var brandText: some View {
        VStack(spacing: DSSpacing.xs) {
            Text("GAHEZ")
                .font(DSFont.splashEyebrow)
                .tracking(4)
                .foregroundStyle(DSColor.textSecondary)

            Text("Movies")
                .font(DSFont.splashTitle)
                .foregroundStyle(DSColor.textPrimary)

            Text("Popular titles, ready when you are.")
                .font(DSFont.splashSubtitle)
                .foregroundStyle(DSColor.textSecondary)
        }
        .multilineTextAlignment(.center)
        .opacity(isAnimatedIn ? 1 : 0)
        .offset(y: isAnimatedIn ? 0 : 12)
    }

    private func ambientGlow(
        color: Color,
        size: CGFloat,
        x: CGFloat,
        y: CGFloat
    ) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 40)
            .offset(x: x, y: y)
    }
}
