//
//  PlayHapticView.swift
//  RhythmTokTokWatchApp
//
//  Created by sungkug_apple_developer_ac on 10/13/24.
//

import SwiftUI
import UserNotifications
import WatchKit

struct PlayHapticView: View {
    @State private var isTimerRunning = false
    @State private var endDate: Date?
    @State private var countdownTimer: Timer?
    @State private var remainingTime: TimeInterval = 0

    let totalTime: TimeInterval = 60 * 5 // 5분

    var body: some View {
        VStack {
            Text("남은 시간")
                .font(.title)
                .padding()
            
            Text("\(timeRemaining())")
                .font(.system(size: 11))
                .padding()
            
            Button(action: {
                if isTimerRunning {
                    stopTimer()
                } else {
                    startTimer()
                }
            }) {
                Text(isTimerRunning ? "타이머 중지" : "타이머 시작")
                    .font(.headline)
            }
            .padding()
        }
    }
    
    func startTimer() {
        endDate = Date().addingTimeInterval(totalTime)
        remainingTime = totalTime
        isTimerRunning = true

        // 1초마다 타이머가 작동하여 매 초마다 실행
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerTick()
        }
    }
    
    func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        isTimerRunning = false
        remainingTime = 0
        endDate = nil
    }
    
    func timerTick() {
        guard let endDate = endDate else { return }
        let currentTime = Date()
        
        // 남은 시간을 계산
        remainingTime = endDate.timeIntervalSince(currentTime)
        
        // 타이머가 종료될 경우
        if remainingTime <= 0 {
            stopTimer()
        }
        
        // 주기적으로 실행할 작업들 (1초마다)
        runScheduledTasks()
    }
    
    // 원하는 작업들을 주기적으로 실행
    func runScheduledTasks() {
        print("현재 남은 시간: \(Int(remainingTime))초")
        // 여기에 주기적으로 실행하고 싶은 코드를 추가
    }
    
    // 남은 시간 표시
    func timeRemaining() -> String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    PlayHapticView()
}
