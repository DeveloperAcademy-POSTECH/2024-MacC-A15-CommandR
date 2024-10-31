//
//  WatchSessionManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//
// ConnectivityManager.swift

import Foundation
import WatchConnectivity
import Combine

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    var hapticManager = HapticScheduleManager()
    @Published var isConnected: Bool = false
    @Published var isSelectedScore: Bool = false
    @Published var selectedScoreTitle: String = ""
    @Published var playStatus: PlayStatus = .ready
    @Published var hapticSequence: [Double] = []
    @Published var isHapticGuideOn: Bool = true
    
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
            guard let self = self else { return }
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
                print("곡 햅틱: \(hapticSequence)")
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
                 case .pause, .stop:
                     self.hapticManager.stopHaptic()
                 case .ready, .done:
                     break
                 }
             } else {
                 ErrorHandler.handleError(error: "알 수 없는 재생 상태")
             }
         }
     }
    
    func sendPlayStatusToPhone(status: PlayStatus, startTime: TimeInterval? = nil) {
        let message: [String: Any] = [
            "playStatus": status.rawValue,
            "startTime": startTime ?? 0 // startTime이 없으면 0으로 설정
        ]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("iPhone으로 메시지 전송 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    // 워치에서 버튼을 누르면 이 메소드를 호출하도록 설정
    func playButtonTapped() {
        if playStatus == .play {
            // 현재 재생 중이면 일시정지로 변경
            playStatus = .pause
            sendPlayStatusToPhone(status: .pause)
            hapticManager.stopHaptic() // 햅틱 중지
        } else {
            // 재생 상태로 변경
            playStatus = .play
            let delaySeconds: TimeInterval = 4.0
            let startTime = Date().addingTimeInterval(delaySeconds).timeIntervalSince1970
            sendPlayStatusToPhone(status: .play, startTime: startTime)
            
            // 4초 후에 햅틱 실행
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
                if self.isHapticGuideOn {
                    self.hapticManager.startHaptic(beatTime: self.hapticSequence, startTimeInterval: startTime)
                } else {
                    print("진동 가이드가 비활성화되어 startHaptic을 실행하지 않습니다.")
                }
            }
        }
    }
    

    func sendPlayStatusToPhone(status: PlayStatus) {
        let message: [String: Any] = ["playStatus": status.rawValue]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("iPhone으로 메시지 전송 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    // 워치에서 버튼을 누르면 이 메소드를 호출하도록 설정
    func playButtonTapped() {
        if playStatus == .play {
            // 현재 재생 중이면 일시정지로 변경
            playStatus = .pause
            sendPlayStatusToPhone(status: .pause)
            hapticManager.stopHaptic() // 햅틱 중지
        } else {
            // 재생 상태로 변경
            playStatus = .play
            sendPlayStatusToPhone(status: .play)
            
            // 이전에 받은 햅틱 시퀀스 실행
            if isHapticGuideOn {
                // 진동 가이드가 활성화된 경우
                let startTime = Date().timeIntervalSince1970
                hapticManager.startHaptic(beatTime: hapticSequence, startTimeInterval: startTime)
            } else {
                // 진동 가이드가 비활성화된 경우
                print("진동 가이드가 비활성화되어 startHaptic을 실행하지 않습니다.")
            }
        }
    }
}
