//
//  WatchConnectivityManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//

import Combine
import Foundation
import HealthKit
import WatchConnectivity
import WatchKit

class WatchtoiOSConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isSelectedScore: Bool = false
    @Published var selectedScoreTitle: String = ""
    @Published var playStatus: PlayStatus = .ready
    @Published var hapticSequence: [Double] = []
    @Published var isHapticGuideOn: Bool = true
    @Published var startTime: TimeInterval?
    @Published var isSending: Bool = false
    
    var hapticManager = HapticScheduleManager()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setupSession()
    }
    
    deinit {
        // 메모리 해제시 로직
        cancellables.removeAll()
    }
    
    // MARK: Watch Connectivity Session 처리
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
    
    // MARK: 백그라운드 세션 활성화 구독
    private func observeHapticSessionActive() {
        hapticManager.$isSessionActive
            .prepend(hapticManager.isSessionActive)  // 현재 값을 먼저 방출
            .sink { [weak self] isActive in
                guard let self = self else { return }
                if isActive {
                    sendSessionStatusToIOS(true)
                } else {
                    sendSessionStatusToIOS(false)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - WCSessionDelegate 메서드
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {

        if activationState == .activated {
            print("워치에서 WCSession 활성화 완료")
            observeHapticSessionActive()
        }
        if let error = error {
            ErrorHandler.handleError(error: "WCSession 활성화 실패 - \(error.localizedDescription)")
        }
    }
    
    // MARK: - iPhone으로부터 Application Context 수신
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            hapticManager.startExtendedSession()

            // Haptic Guide 설정 업데이트
            self.updateHapticGuideSetting(applicationContext)
            
            // 곡 제목과 햅틱 시퀀스 업데이트
            self.updateScoreAndHapticSequence(applicationContext)
            
            // 재생 상태 업데이트
            self.updatePlayStatus(applicationContext)
            
            sendSessionStatusToIOS(hapticManager.isSessionActive)
        }
    }

    // MARK: - Haptic Guide 설정 업데이트
    private func updateHapticGuideSetting(_ applicationContext: [String: Any]) {
        if let isHapticGuideOn = applicationContext["watchHapticGuide"] as? Bool {
            self.isHapticGuideOn = isHapticGuideOn
            print("워치에서 수신한 watchHapticGuide 설정: \(self.isHapticGuideOn)")
        }
    }

    // MARK: - 곡 제목과 햅틱 시퀀스 업데이트
    private func updateScoreAndHapticSequence(_ applicationContext: [String: Any]) {
        if let scoreTitle = applicationContext["scoreTitle"] as? String,
           let hapticSequence = applicationContext["hapticSequence"] as? [Double] {
            self.hapticManager.stopHaptic()
            self.selectedScoreTitle = scoreTitle
            self.hapticSequence = hapticSequence
            self.isSelectedScore = !scoreTitle.isEmpty
        } else {
            ErrorHandler.handleError(error: "받은 햅틱이 없습니다")
        }
    }

    // MARK: - 재생 상태 업데이트
    private func updatePlayStatus(_ applicationContext: [String: Any]) {
        if let playStatusString = applicationContext["playStatus"] as? String,
           let playStatus = PlayStatus(rawValue: playStatusString) {
            self.playStatus = playStatus
            self.isSending = false
        
            switch playStatus {
            case .play:
                if let startTime = applicationContext["startTime"] as? TimeInterval {
                    self.startTime = startTime
                    if self.isHapticGuideOn {
                        // 진동 가이드가 활성화된 경우
                        self.hapticManager.startHaptic(beatTime: self.hapticSequence, startTimeInterval: startTime)
                    } else {
                        ErrorHandler.handleError(error: "진동 가이드가 비활성화되어 startHaptic을 실행하지 않습니다.")
                    }
                } else {
                    ErrorHandler.handleError(error: "시작 시간 누락")
                }
            case .pause, .stop, .jump:
                self.hapticManager.stopHaptic()
            case .ready:
                WKInterfaceController.reloadRootPageControllers(withNames: [],
                                                                contexts: [], orientation: .horizontal, pageIndex: 0)
            case .done:
                break
            }
        } else {
            ErrorHandler.handleError(error: "알 수 없는 재생 상태")
        }
    }
    
    // 아이폰으로 상태 변화 요청
    func playButtonTapped() {
        isSending = true
        sendPlayStatusToiOS(status: .play)
        
        // 10초 타임아웃 추가
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.isSending = false
        }
    }
    
    // 일시정지 버튼을 누르면 호출되는 함수
    func pauseButtonTapped() {
        isSending = true
        sendPlayStatusToiOS(status: .pause)
        hapticManager.stopHaptic()
        
        // 10초 타임아웃 추가
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.isSending = false
        }
    }
    
//    // MARK: 아이폰으로 Context 전달
//    // 플레이 상태 전달
//    private func sendPlayStatusToiOS(status: PlayStatus) {
//        let message = ["playStatus": status.rawValue]
//        do {
//            print("아이폰에 상태 본냄\(status)")
//            if WCSession.default.activationState == .activated {
//                print("활성화되어있음")
//            }
//            try WCSession.default.updateApplicationContext(message)
//        } catch {
//            ErrorHandler.handleError(error: error)
//        }
//    }
    private func sendPlayStatusToiOS(status: PlayStatus) {
        let message = ["playStatus": status.rawValue]

        // 연결 상태 확인
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: { response in
                // 응답 처리 (필요 시)
                print("iPhone acknowledged the message with response: \(response)")
            }, errorHandler: { error in
                // 에러 처리
                print("Failed to send message to iPhone: \(error.localizedDescription)")
            })
            print("Sent play status to iPhone: \(status.rawValue)")
        } else {
            print("iPhone is not reachable. Cannot send play status.")
        }
    }
    
    // Background Session 활성화 여부 상태 전달
    private func sendSessionStatusToIOS(_ isActive: Bool) {
        let userInfo: [String: Any] = [
            "SessionStatus": isActive,
            "Timestamp": Date().timeIntervalSince1970 // 현재 타임스탬프
        ]
   
        if WCSession.default.activationState == .activated {
            WCSession.default.transferUserInfo(userInfo)
            print("User info transferred using transferUserInfo with status: \(isActive)")
        } else {
            print("WCSession is not activated. Unable to transfer user info.")
        }
    }
}
