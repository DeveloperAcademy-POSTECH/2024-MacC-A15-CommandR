//
//  WatchManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/8/24.

import HealthKit
import UIKit
import WatchConnectivity

class IOStoWatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = IOStoWatchConnectivityManager()
    // 아래 곡 제목에 실제 곡 제목을 넣어주세용
    var selectedScoreTitle: String?
    // 런치 용도
    let healthStore = HKHealthStore()
    let allTypes = Set([HKObjectType.workoutType()])
    let configuration = HKWorkoutConfiguration()
    
    @Published var isWatchAppConnected: Bool = false
    @Published var playStatus: PlayStatus = .ready
    // 워치로부터 받은 상태, 시간
    @Published var receivedPlayStatus: PlayStatus = .ready
    @Published var receivedStartTime: TimeInterval?
    
    private override init() {
        super.init()
        setupSession()
    }
    
    // WCSession 설정
    private func setupSession() {
        guard WCSession.isSupported() else {
            ErrorHandler.handleError(error: "WCSession 지원되지 않음")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("iPhone 앱에서 WCSession 활성화 요청")
    }
    
    // MARK: - WCSessionDelegate 메서드
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("iPhone에서 WCSession 활성화 완료")
        }
        if let error = error {
            ErrorHandler.handleError(error: "WCSession 활성화 실패 - \(error.localizedDescription)")
        }
        updateWatchAppReachability(session)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        isWatchAppConnected = false
        print("WCSession 비활성화됨")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        isWatchAppConnected = false
        print("WCSession 비활성화됨 - 다시 활성화 준비")
        WCSession.default.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        updateWatchAppReachability(session)
    }
    
    private func updateWatchAppReachability(_ session: WCSession) {
        DispatchQueue.main.async {
//            if session.isReachable {
//                self.isWatchAppConnected = true
//            }
            print("isWatchAppReachable: \(self.isWatchAppConnected)")
        }
    }
    
    // MARK: - 워치 런치
    func launchWatch() async -> Bool {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else {
            self.isWatchAppConnected = false
            ErrorHandler.handleError(error: "Apple Watch가 연결되어 있지 않거나 앱이 설치되어 있지 않습니다.")
            return false
        }
        
        // HealthKit 권한 요청
        let authorizationSuccess = await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else {
                    ErrorHandler.handleError(error: error ?? "HealthKit 권한 요청 실패")
                    continuation.resume(returning: false)
                }
            }
        }
        
        guard authorizationSuccess else {
            self.isWatchAppConnected = false
            return false
        }

        // `startAppTask` 및 `timeoutTask` 병렬 실행
        let startAppTask = Task { () -> Bool in
            do {
                try await self.healthStore.startWatchApp(toHandle: self.configuration)
                self.isWatchAppConnected = true
                return true
            } catch {
                self.isWatchAppConnected = false
                return false
            }
        }
        
        let timeoutTask = Task { () -> Bool in
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5초 타임아웃
            return false
        }

        // `timeoutTask`가 먼저 완료되면 `startAppTask` 취소
        let result: Bool
        if let completedResult = await withCheckedContinuation({ continuation in
            Task {
                if await timeoutTask.value == false {
                    startAppTask.cancel()
                    continuation.resume(returning: false)
                    ErrorHandler.handleError(error: "Apple Watch가 꺼져 있거나 배터리가 부족할 수 있습니다. 배터리를 확인하거나 Watch가 켜져 있는지 확인해 주세요.")
                } else {
                    continuation.resume(returning: await startAppTask.value)
                }
            }
        }) {
            result = completedResult
        } else {
            result = false
        }
        
        return result
    }
    
    // MARK: - 워치로 메시지 보내는 부분
    // 곡 선택 후 [제목],[햅틱시퀀스] 보냄 (리스트뷰에서 곡을 선택할 때 작동)
    func sendScoreSelection(scoreTitle: String, hapticSequence: [Double]) {
        self.selectedScoreTitle = scoreTitle
        let message: [String: Any] = [
            "scoreTitle": scoreTitle,
            "playStatus": PlayStatus.ready.rawValue,
            "hapticSequence": hapticSequence
        ]
        print("전체 햅틱 갯수 \(hapticSequence.count)")
        do {
            try WCSession.default.updateApplicationContext(message)
//            print("워치로 곡 선택 메시지 전송 완료: \(message)")
        } catch {
            self.isWatchAppConnected = false
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
        }
    }
    
    // 마디 점프 요청
    func sendUpdateStatusWithHapticSequence(scoreTitle: String, hapticSequence: [Double], status: PlayStatus, startTime: TimeInterval) {
        self.selectedScoreTitle = scoreTitle
        let watchHapticGuide = UserSettingData.shared.getIsHapticOn()

        var message: [String: Any] = [
            "scoreTitle": scoreTitle,
            "playStatus": status.rawValue,
            "watchHapticGuide": watchHapticGuide,
            "startTime": startTime
        ]
        
        // play 상태가 아닐때만 
        if status != .play {
            message["hapticSequence"] = hapticSequence
        }
        
        do {
            try WCSession.default.updateApplicationContext(message)
//            print("워치로 곡 선택 메시지 전송 완료: \(message)")
        } catch {
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
            self.isWatchAppConnected = false
        }
    }
    
    // 워치 playStatus 변환 요청
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            if let playStatusString = applicationContext["playStatus"] as? String,
               let receivedPlayStatus = PlayStatus(rawValue: playStatusString) {
                self.receivedPlayStatus = receivedPlayStatus
                print("워치로부터 수신한 재생 상태: \(receivedPlayStatus.rawValue)")
                
                // 상태 변경에 대한 알림을 전송
                if receivedPlayStatus == .play {
                    NotificationCenter.default.post(name: .watchPlayButtonTapped, object: nil)
                } else if receivedPlayStatus == .pause {
                    NotificationCenter.default.post(name: .watchPauseButtonTapped, object: nil)
                }
            }
            if let sessionStatus = applicationContext["SessionStatus"] as? Bool {
                // TODO: 여기서 워치랑 통신 가능 상태 관리하는 변수 처리
                self.isWatchAppConnected = sessionStatus
                print("전달 \(sessionStatus)")
            }
        }
    }
}
