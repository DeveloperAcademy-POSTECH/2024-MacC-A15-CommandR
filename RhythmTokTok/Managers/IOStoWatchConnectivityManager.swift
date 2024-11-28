//
//  WatchManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/8/24.

import UIKit
import WatchConnectivity

class IOStoWatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = IOStoWatchConnectivityManager()
    // 아래 곡 제목에 실제 곡 제목을 넣어주세용
    var scoreTitle: String?
    private var creationTimestamp: TimeInterval = 0 // 마지막 처리된 데이터의 타임스탬프

    // 런치 용도
//    let healthStore = HKHealthStore()
//    let allTypes = Set([HKObjectType.workoutType()])
//    let configuration = HKWorkoutConfiguration()
    
    @Published var watchAppStatus: AppleWatchStatus = .ready
    @Published var playStatus: PlayStatus = .ready
    // 워치로부터 받은 상태, 시간
    @Published var receivedPlayStatus: PlayStatus = .ready
    @Published var receivedStartTime: TimeInterval?
    
    private override init() {
        super.init()
        setupSession()
        creationTimestamp = Date().timeIntervalSince1970
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
        watchAppStatus = .disconnected
        print("WCSession 비활성화됨")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        watchAppStatus = .disconnected
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
            print("isWatchAppReachable: \(self.watchAppStatus)")
        }
    }
    
    // MARK: - 워치 런치
    func launchWatch() async -> Bool {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else {
            self.watchAppStatus = .notInstalled
            ErrorHandler.handleError(error: "Apple Watch가 연결되어 있지 않거나 앱이 설치되어 있지 않습니다.")
            return false
        }
        
        let result = await withTaskGroup(of: Bool.self) { group -> Bool in
//            // startAppTask 추가
//            group.addTask {
//                do {
//                    try await self.healthStore.startWatchApp(toHandle: self.configuration)
//                    print("startAppTask 성공")
//                    return true
//                } catch {
//                    return false
//                }
//            }
            
            // timeoutTask 추가 (5초 타임아웃)
            group.addTask {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5초 대기
                print("timeoutTask 완료 (타임아웃)")
                return false
            }
            
            // 첫 번째로 완료된 작업의 결과를 반환하고 나머지 작업은 취소
            if let firstResult = await group.next() {
                group.cancelAll()
                if !firstResult {
                    self.watchAppStatus = .lowBattery
                    ErrorHandler.handleError(error: "Apple Watch가 꺼져 있거나 배터리가 부족할 수 있습니다. 배터리를 확인하거나 Watch가 켜져 있는지 확인해 주세요.")
                }
                print("결과 \(firstResult)")
                return firstResult
            } else {
                return false
            }
        }
        
        return result
    }
    
    // MARK: - 워치로 메시지 보내는 부분
    // 곡 선택 후 [제목],[햅틱시퀀스] 보냄 (리스트뷰에서 곡을 선택할 때 작동)
    func sendScoreSelection(scoreTitle: String, hapticSequence: [Double]) {
        self.scoreTitle = scoreTitle
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
            if self.watchAppStatus == .connected {
                self.watchAppStatus = .disconnected
            }
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
        }
    }
    
    // 마디 점프 요청
    func sendUpdateStatusWithHapticSequence(currentScore: Score, hapticSequence: [Double], status: PlayStatus, startTime: TimeInterval) {
        self.scoreTitle = currentScore.title
        let watchHapticGuide = currentScore.hapticOption

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
        } catch {
            if self.watchAppStatus == .connected {
                self.watchAppStatus = .disconnected
            }
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        DispatchQueue.main.async {
            guard let isActive = userInfo["SessionStatus"] as? Bool,
                  let timestamp = userInfo["Timestamp"] as? TimeInterval else {
                print("Invalid or missing data")
                return
            }

            // 생성 타임스탬프보다 최신 데이터만 처리
            if timestamp > self.creationTimestamp {
                print("Processing new SessionStatus: \(isActive) at \(timestamp)")

                if isActive {
                    self.watchAppStatus = .connected
                } else if self.watchAppStatus == .connected || self.watchAppStatus == .ready {
                    print("백그라운드 세션 안됨 받음")
                    self.watchAppStatus = .backgroundInactive
                }
            } else {
                print("Ignoring outdated SessionStatus data")
            }
        }
    }
}
