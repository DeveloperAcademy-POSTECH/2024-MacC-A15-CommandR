//
//  MarqueeText.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 10/15/24.
//

import SwiftUI

struct WatchScoreTitleView: View {
    let text: String
    let fontSize: CGFloat
    let isAnimating: Bool
    let speed: Double = 30 // 속도 조절 (포인트/초)

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width

            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: fontSize))
                .lineLimit(1)
                .truncationMode(.tail)
            
                .background(
                    GeometryReader { textGeometry in
                        Color.clear
                            .onAppear {
                                self.textWidth = textGeometry.size.width
                                self.containerWidth = containerWidth
                                
                                // 애니메이션 시작 조건 확인
                                if isAnimating && textWidth > containerWidth {
                                    startAnimation()
                                }
                            }
                    }
                )
                .offset(x: offset)
                .onAppear {
                    if isAnimating {
                        startAnimation()
                    }
                }
                .onDisappear {
                    stopAnimation()
                }
                .onChange(of: isAnimating) { _, newValue in
                    // 애니메이션 상태 변경 시 애니메이션 시작 또는 중지
                    if newValue {
                        startAnimation()
                    } else {
                        stopAnimation()
                    }
                }
        }
        .frame(height: fontSize + 4) // 텍스트 높이 설정
        .clipped() // 텍스트가 컨테이너를 벗어나지 않도록 잘라냄
    }

    /// 애니메이션 시작
    private func startAnimation() {
        stopAnimation() // 기존 타이머 중지

        offset = containerWidth // 텍스트 시작 위치 설정 (오른쪽 끝)

        let totalDistance = textWidth + containerWidth
        let animationDuration = Double(totalDistance) / speed

        // 타이머 간격 및 이동 거리 설정
        let updateInterval = 0.01 // 0.01초마다 업데이트
        let distancePerTick = CGFloat(speed * updateInterval) // 한 번에 이동할 거리

        // 타이머 시작
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            withAnimation(.linear(duration: updateInterval)) {
                offset -= distancePerTick
            }

            // 텍스트가 왼쪽 끝에 도달하면 다시 시작 위치로 리셋
            if offset <= -textWidth {
                offset = containerWidth
            }
        }
    }

    /// 애니메이션 중지
    private func stopAnimation() {
        timer?.invalidate() // 타이머 중지
        timer = nil
        offset = 0 // 오프셋 초기화
    }
}
