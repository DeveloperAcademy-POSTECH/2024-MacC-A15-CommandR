//
//  MarqueeText.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 10/15/24.
//

import SwiftUI

struct MarqueeTextView: View {
    let text: String
    let fontSize: CGFloat
    let isAnimating: Bool
    let speed: Double = 30 // 속도 조절 (포인트/초)

    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width

            Text(text)
                .font(.system(size: fontSize))
                .lineLimit(1)
                .fixedSize()
                .background(
                    GeometryReader { textGeometry in
                        Color.clear
                            .onAppear {
                                self.textWidth = textGeometry.size.width
                                self.containerWidth = containerWidth
                                if isAnimating && textWidth > containerWidth {
                                    startAnimation()
                                }
                            }
                    }
                )
                .offset(x: offset)
                .onAppear {
                    if isAnimating && textWidth > containerWidth {
                        startAnimation()
                    }
                }
                .onDisappear {
                    stopAnimation()
                }
                .onChange(of: isAnimating) { newValue in
                    if newValue {
                        if textWidth > containerWidth {
                            startAnimation()
                        }
                    } else {
                        stopAnimation()
                    }
                }
        }
        .frame(height: fontSize + 4)
        .clipped()
    }

    private func startAnimation() {
        stopAnimation() // 기존 타이머 중지
        guard isAnimating, textWidth > containerWidth else {
            offset = 0
            return
        }

        offset = containerWidth

        let animationInterval = 0.01
        let distancePerTick = CGFloat(speed * animationInterval)

        timer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { _ in
            withAnimation(.linear(duration: animationInterval)) {
                offset -= distancePerTick
            }
            if offset <= -textWidth {
                offset = containerWidth
            }
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
        offset = 0
    }
}
