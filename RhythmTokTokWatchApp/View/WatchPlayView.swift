//
//  WatchPlayView.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 10/15/24.
//
import SwiftUI

struct WatchPlayView: View {
    @EnvironmentObject var connectivityManager: WatchtoiOSConnectivityManager
    @State private var countdownNumber: Int?
    @State private var timer: Timer?
    
    private var scoreStatusText: String {
        switch connectivityManager.playStatus {
        case .ready, .stop:
            return "준비"
        case .play:
            return "재생중"
        case .pause, .jump:
            return "일시정지"
        case .done:
            return "연습완료"
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .center) {
                    Spacer()
                    Text(scoreStatusText)
                        .foregroundColor(.blue)
                        .font(.headline)
                }
                .padding(.trailing, 10)
                
                // 곡 타이틀 표시
                WatchScoreTitleView(
                    text: connectivityManager.selectedScoreTitle,
                    fontSize: 20,
                    isAnimating: connectivityManager.playStatus == .play
                )
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                Spacer()
                Button {
                    if connectivityManager.playStatus == .play {
                        // 재생 중일 때 일시정지 동작
                        connectivityManager.pauseButtonTapped()
                    } else {
                        // 일시정지 또는 준비 상태일 때 재생 동작
                        connectivityManager.playButtonTapped()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue05)
                        
                        Image(systemName: connectivityManager.playStatus != .play ?
                              "play.fill" : "pause.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(.white)
                    }
                    .frame(height: 64)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 10)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
            
            // 카운트다운 뷰 (countdownNumber가 nil이 아닐 때만 표시)
            if countdownNumber != nil {
                WatchCountdownView(countdownNumber: $countdownNumber)
            }
        }
        .onReceive(connectivityManager.$startTime) { newStartTime in
            if connectivityManager.playStatus == .play,
               let startTime = newStartTime {
                scheduleCountdown(startTime: startTime)
            }
        }
        .onDisappear {
            stopCountdown()
        }
    }
    
    private func scheduleCountdown(startTime: TimeInterval) {
        stopCountdown()
        
        let currentTime = Date().timeIntervalSince1970
        let countdownStartTime = startTime - 3
        let delay = countdownStartTime - currentTime
        
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                startCountdown()
            }
        } else {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        countdownNumber = 3
        playHaptic(for: 3)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let currentNumber = countdownNumber, currentNumber > 1 {
                countdownNumber = currentNumber - 1
                playHaptic(for: currentNumber - 1)
            } else {
                countdownNumber = nil
                stopCountdown()
            }
        }
    }
    
    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    private func playHaptic(for number: Int) {
        if connectivityManager.isHapticGuideOn {
            switch number {
            case 3:
                WKInterfaceDevice.current().play(.retry)
            case 2:
                WKInterfaceDevice.current().play(.retry)
            case 1:
                WKInterfaceDevice.current().play(.retry)
            default:
                break
            }
        }
    }
}

struct WatchPlayView_Previews: PreviewProvider {
    static var previews: some View {
        // 샘플 데이터를 가진 ConnectivityManager 생성
        let manager = WatchtoiOSConnectivityManager()
        manager.selectedScoreTitle = "This is a long song title that should scroll across the screen"
        manager.playStatus = .play
        return WatchPlayView()
            .environmentObject(manager)
    }
}

//#Preview {
//    WatchPlayView()
//        .environmentObject(ConnectivityManager())
//}
