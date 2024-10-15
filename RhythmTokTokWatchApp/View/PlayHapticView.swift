//
//  PlayHapticView.swift
//  RhythmTokTokWatchApp
//
//  Created by sungkug_apple_developer_ac on 10/13/24.
//

import SwiftUI

struct PlayHapticView: View {
    @State private var hapticManager = HapticScheduleManager()
    @State private var tempo: Double = 120.0  // 템포 초기값 (BPM)
    @State private var isPlay = false

    // 나중에 여기에 실행할 햅틱 대입해주면 됨
    let exampleBeatTimes: [Double] = [0.5/*쉼표 1.0 추가*/, 0.5, 1.0, 0.5, 0.5,
                               1.0, 1.0, 3.0/*쉼표 1.0 추가*/,
                               0.5, 0.5, 1.0, 0.5, 0.5,
                               1.0, 1.0, 2.0/*쉽표 1.0추가*/,
                               1.5/*쉼표 1.0 추가*/, 0.5, 1.0, 0.5, 0.5,
                               1.0, 1.0, 1.0, 1.0,
                               2.0, 2.0,
                               4.0,
                               // 도돌이표A
                               0.5/*쉼표 1.0 추가*/, 0.5, 1.0, 0.5, 0.5,
                               1.0, 1.0, 3.0/*쉼표 1.0 추가*/,
                               0.5, 0.5, 1.0, 0.5, 0.5,
                               1.0, 1.0, 2.0/*쉽표 1.0추가*/,
                               1.5/*쉼표 1.0 추가*/, 0.5, 1.0, 0.5, 0.5,
                               1.0, 1.0, 1.0, 1.0,
                               2.0, 2.0,
                               4.0,
                               // 도돌이표A
                               1.0, 1.0, 1.0, 1.0,
                               1.0, 0.5, 0.5, 0.5, 0.5, 1.0,
                               1.0, 1.0, 1.0, 1.0,
                               1.0, 0.5, 0.5, 0.5, 0.5, 1.0,
                               1.0, 1.0, 1.0, 1.0,
                               1.0, 0.5, 0.5, 1.0, 1.0,
                               5.0/*쉼표 2.0 추가 + 쉼표 1.0 추가*/,
                               1.0, 0.5, 0.5, 1.0,
                               // 도돌이표 B
                               0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0,
                               0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0,
                               0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
                               0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0,
                               // 도돌이표 B
                               0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0,
                               0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1.0,
                               0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
                               0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 2.0/*쉼표 1.0 추가*/,
                               // 도돌이표 B
                               1.0, 1.0, 1.0]
    var testHaptic: [Double] = [0.0, 1.8, 2.4, 3.6, 4.5, 4.8, 5.1, 5.25, 6.45, 7.05, 7.95, 8.25, 8.55, 8.85, 10.05, 10.65, 12.45, 13.65]

    var body: some View {
        VStack {
            Text("Pick Me")
                .font(.title)
                .padding()
            
            Button(action: {
                if isPlay {
                    hapticManager.stopHaptic()
                } else {
                    hapticManager.starHaptic(beatTime: testHaptic)
                }
                
                isPlay.toggle()
            }, label: {
                Text(isPlay ? "정지" : "햅틱 시작")
                    .font(.headline)
            })
            .padding()
        }
    }
}

#Preview {
    PlayHapticView()
}
