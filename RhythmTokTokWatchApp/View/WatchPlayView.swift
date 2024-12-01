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
                            .fill(Color.blue500)
                        
                        if connectivityManager.isSending {
                            // 로딩 상태일 때 ProgressView 표시
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(height: 24)
                                .foregroundColor(.white)
                        } else {
                            // 재생/일시정지 아이콘
                            Image(systemName: connectivityManager.playStatus != .play ?
                                  "play.fill" : "pause.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundColor(.white)
                        }
                    }
                    .frame(height: 64)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 10)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
            .disabled(connectivityManager.isSending) // 버튼 활성화/비활성화 조건
            
            // 카운트다운 뷰 (countdownNumber가 nil이 아닐 때만 표시)
            if countdownNumber != nil {
                WatchCountdownView(countdownNumber: $countdownNumber)
            }
        }
        .onReceive(connectivityManager.$startTime) { newStartTime in
            if connectivityManager.playStatus == .play,
               let startTime = newStartTime {
                scheduleCountdown(for: startTime)
            }
        }
        .onDisappear {
            stopCountdown()
        }
    }
    
    private func scheduleCountdown(for startTime: TimeInterval) {
        stopCountdown()

        let currentTime = Date().timeIntervalSince1970
        let timeRemaining = startTime - currentTime
        
        if timeRemaining > 0 {
            countdownNumber = Int(ceil(timeRemaining)) // 남은 시간 정수화
            startCountdown(for: startTime)
        } else {
            countdownNumber = nil
        }
    }

    private func startCountdown(for startTime: TimeInterval) {
        let currentTime = Date().timeIntervalSince1970
        let timeRemaining = startTime - currentTime // 시작 시간까지 남은 시간 계산

        if timeRemaining > 3 {
            // 3초 이상 남았을 경우, (timeRemaining - 3)만큼 대기 후 카운트다운 시작
            let delay = timeRemaining - 3
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.beginCountdown(from: 3) // 3초부터 시작
            }
        } else if timeRemaining > 0 {
            // 3초보다 적게 남았을 경우, 남은 시간만큼 대기한 후 카운트다운 시작
            let delay = timeRemaining.truncatingRemainder(dividingBy: 1) // 초 단위 대기 시간
            let startNumber = Int(floor(timeRemaining)) // 정수로 내림하여 시작 숫자 계산

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.beginCountdown(from: startNumber)
            }
        } else {
            // 남은 시간이 0 이하인 경우 종료
            countdownNumber = nil
        }
    }

    // 카운트다운 실행 로직
    private func beginCountdown(from startNumber: Int) {
        countdownNumber = startNumber
        playHaptic(for: startNumber)

        // 정확히 1초 간격으로 Timer 설정
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let currentCountdown = countdownNumber, currentCountdown > 1 {
                countdownNumber = currentCountdown - 1
                playHaptic(for: currentCountdown - 1)
            } else {
                countdownNumber = nil
                stopCountdown()
            }
        }
    }

    private func stopCountdown() {
        timer?.invalidate()
        timer = nil
        countdownNumber = nil
    }

    private func playHaptic(for number: Int) {
        guard connectivityManager.isHapticGuideOn else { return }
        switch number {
        case 3, 2, 1:
            WKInterfaceDevice.current().play(.retry)
        default:
            break
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
