//
//  WatchConnectivityManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//

import Foundation
import WatchConnectivity
import Combine

class WatchtoiOSConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    var hapticManager = HapticScheduleManager()
    @Published var isConnected: Bool = false
    @Published var isSelectedScore: Bool = false
    @Published var selectedScoreTitle: String = ""
    @Published var playStatus: PlayStatus = .ready
    @Published var hapticSequence: [Double] = []
    @Published var isHapticGuideOn: Bool = true
    @Published var startTime: TimeInterval?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            ErrorHandler.handleError(error: "WCSession 지원되지 않음")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("watchOS 앱에서 WCSession 활성화 요청")
    }
    
    // MARK: - WCSessionDelegate 메서드
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if activationState == .activated {
            print("워치에서 WCSession 활성화 완료")
            DispatchQueue.main.async {
                self.isConnected = session.isReachable
                self.hapticManager.startExtendedSession()
            }
        }
        if let error = error {
            ErrorHandler.handleError(error: "WCSession 활성화 실패 - \(error.localizedDescription)")
        }
    }
    
    // MARK: - iPhone으로부터 Application Context 수신
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return }
            session.activate()
            if let isHapticGuideOn = applicationContext["watchHapticGuide"] as? Bool {
                self.isHapticGuideOn = isHapticGuideOn
                print("워치에서 수신한 watchHapticGuide 설정: \(self.isHapticGuideOn)")
            }
            
            // 1. 곡 선택 후 [제목], [햅틱 시퀀스] 받음
            if let scoreTitle = applicationContext["scoreTitle"] as? String,
               let hapticSequence = applicationContext["hapticSequence"] as? [Double] {
                self.hapticManager.stopHaptic()
                self.selectedScoreTitle = scoreTitle
                self.hapticSequence = hapticSequence
                self.isSelectedScore = !scoreTitle.isEmpty
                print("곡 선택 완료, 곡 제목: \(scoreTitle)")
                print("곡 햅틱 갯수: \(hapticSequence.count)")
            } else {
                print("햅틱 셋팅 없음")
            }
            // 2. 연습뷰에서 [재생 상태]를 받음. 재생인 경우 [시작 시간] 받음.
            if let playStatusString = applicationContext["playStatus"] as? String,
               let playStatus = PlayStatus(rawValue: playStatusString) {
                self.playStatus = playStatus
                print("재생 상태 업데이트: \(playStatus.rawValue)")
                
                switch playStatus {
                case .play:
                    if let startTime = applicationContext["startTime"] as? TimeInterval {
                        print("시작 시간 수신: \(startTime)")
                        self.startTime = startTime
                        if self.isHapticGuideOn {
                            // 진동 가이드가 활성화된 경우
                            self.hapticManager.startHaptic(beatTime: self.hapticSequence, startTimeInterval: startTime)
                        } else {
                            // 진동 가이드가 비활성화된 경우
                            print("진동 가이드가 비활성화되어 startHaptic을 실행하지 않습니다.")
                        }
                    } else {
                        ErrorHandler.handleError(error: "시작 시간 누락")
                    }
                case .pause, .stop, .jump:
                    self.hapticManager.stopHaptic()
                case .ready, .done:
                    break
                }
            } else {
                ErrorHandler.handleError(error: "알 수 없는 재생 상태")
            }
        }
    }
    // 아이폰으로 상태 변화 요청
    func playButtonTapped() {
        playStatus = .play
        sendPlayStatusToiOS(status: .play)
    }
    
    // 일시정지 버튼을 누르면 호출되는 함수
    func pauseButtonTapped() {
        playStatus = .pause
        sendPlayStatusToiOS(status: .pause)
        hapticManager.stopHaptic()
    }
    
    private func sendPlayStatusToiOS(status: PlayStatus) {
        let message = ["playStatus": status.rawValue]
        do {
            try WCSession.default.updateApplicationContext(message)
        } catch {
            print("Error sending play status: \(error.localizedDescription)")
        }
    }
}
