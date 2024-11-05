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

class WatchtoiOSConnectivityManager: NSObject, ObservableObject, WCSessionDelegate, HKWorkoutSessionDelegate {
    @Published var isSelectedScore: Bool = false
    @Published var selectedScoreTitle: String = ""
    @Published var playStatus: PlayStatus = .ready
    @Published var hapticSequence: [Double] = []
    @Published var isHapticGuideOn: Bool = true
    @Published var startTime: TimeInterval?
    private var hapticManager = HapticScheduleManager()
    private var workoutSession: HKWorkoutSession?
    private let healthStore = HKHealthStore()

    override init() {
        super.init()
        setupSession()
    }
    
    deinit {
        // 메모리 해제시 워크아웃 종료
        stopWorkoutSession()
    }
    
    // MARK: HeathKit Workout Session 처리
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("워크아웃 상태 변화")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        print("워크아웃 활성화 실패")
    }
    
    func startWorkoutSession() {
        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .indoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            workoutSession?.delegate = self
            workoutSession?.startActivity(with: Date())
        } catch {
            ErrorHandler.handleError(error: error)
        }
    }
    
    func stopWorkoutSession() {
        workoutSession?.end()
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
    
    func activationStateDescription(for state: WCSessionActivationState) -> String {
        switch state {
        case .notActivated:
            return "Not Activated"
        case .inactive:
            return "Inactive"
        case .activated:
            return "Activated"
        @unknown default:
            return "Unknown"
        }
    }
    
    // MARK: - WCSessionDelegate 메서드
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {

        if activationState == .activated {
            print("워치에서 WCSession 활성화 완료")
            DispatchQueue.main.async {
                self.startWorkoutSession()
                self.hapticManager.setupHapticActivationListener()
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
//            session.activate()
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
            } else {
                ErrorHandler.handleError(error: "받은 햅틱이 없습니다")
            }
            // 2. 연습뷰에서 [재생 상태]를 받음. 재생인 경우 [시작 시간] 받음.
            if let playStatusString = applicationContext["playStatus"] as? String,
               let playStatus = PlayStatus(rawValue: playStatusString) {
                self.playStatus = playStatus
                print("재생 상태 업데이트: \(playStatus.rawValue)")
                
                switch playStatus {
                case .play:
                    if let startTime = applicationContext["startTime"] as? TimeInterval {
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
