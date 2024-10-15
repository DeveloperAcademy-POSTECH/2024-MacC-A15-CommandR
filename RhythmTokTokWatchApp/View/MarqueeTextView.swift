//
//  MarqueeText.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 10/15/24.
//

import SwiftUI

struct MarqueeTextView: View {
    let text: String
    let font: Font
    let animate: Bool

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var animationOffset: CGFloat = 0

    @State private var animationTimer: Timer?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // 상단 공간을 채워서 중앙 배치

                HStack {
                    Text(text)
                        .font(font)
                        .lineLimit(1)
                        .fixedSize()
                        .background(
                            GeometryReader { textGeometry in
                                Color.clear
                                    .onAppear {
                                        textWidth = textGeometry.size.width
                                        containerWidth = geometry.size.width
                                        resetAnimation()
                                    }
                            }
                        )
                        .offset(x: animationOffset)
                        .onAppear {
                            if animate {
                                startAnimation()
                            }
                        }
                        .onChange(of: animate) { _, newValue in
                            if newValue {
                                startAnimation()
                            } else {
                                stopAnimation()
                            }
                        }
                }
                .frame(width: containerWidth, alignment: .leading)
                .clipped()

                Spacer() // 하단 공간을 채워서 중앙 배치
            }
            .frame(height: geometry.size.height)
        }
    }

    private func startAnimation() {
        guard textWidth > containerWidth else {
            // 텍스트가 컨테이너보다 작으면 애니메이션 필요 없음
            animationOffset = 0
            return
        }

        // 애니메이션 타이머가 이미 실행 중이면 중지
        animationTimer?.invalidate()

        // 애니메이션 초기 설정
        animationOffset = containerWidth

        let totalDistance = textWidth + containerWidth
        let animationDuration = Double(totalDistance) / 30 // 속도 조절

        // 애니메이션 타이머 시작
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            withAnimation(.linear(duration: 0.01)) {
                animationOffset -= CGFloat(totalDistance) / CGFloat(animationDuration * 100)
            }

            // 애니메이션이 끝나면 초기화
            if animationOffset <= -textWidth {
                animationOffset = containerWidth
            }
        }
    }

    private func stopAnimation() {
        // 애니메이션 타이머 중지
        animationTimer?.invalidate()
        animationTimer = nil

        // 애니메이션 오프셋 초기화
        withAnimation(.none) {
            animationOffset = 0
        }
    }

    private func resetAnimation() {
        animationOffset = animate && textWidth > containerWidth ? containerWidth : 0
    }
}
