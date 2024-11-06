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
            
            ZStack {
                
                // 실제 너비를 측정하기 위한 숨겨진 텍스트
                Text(text)
                    .font(Font.custom("Pretendard-Bold", size: fontSize))
                    .background(GeometryReader { textGeometry in
                        Color.clear
                            .onAppear {
                                self.textWidth = textGeometry.size.width
                            }

                    })
                    .hidden()
                
                if isAnimating {
                    Text(text)
                        .font(Font.custom("Pretendard-Bold", size: fontSize))
                        .lineLimit(1)
                        .frame(width: 200)
                        .offset(x: offset)
                        .onAppear {
                            self.containerWidth = textWidth
                            startAnimation()
                        }
                        .onDisappear {
                            stopAnimation()
                        }
                } else {
                    Text(text)
                        .font(Font.custom("Pretendard-Bold", size: fontSize))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: containerWidth)
                }
            }
        }
        .frame(height: fontSize + 4) // 텍스트 높이 설정
    }
    
    /// 애니메이션 시작
    private func startAnimation() {
        stopAnimation() // 기존 타이머 중지
        
        offset = 0
        
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
