//
//  WatchManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/8/24.

import HealthKit
import UIKit
import WatchConnectivity

class WatchManager: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = WatchManager()
    // 아래 곡 제목에 실제 곡 제목을 넣어주세용
    var selectedScoreTitle: String?
    // 런치 용도
    let healthStore = HKHealthStore()
    let allTypes = Set([HKObjectType.workoutType()])
    let configuration = HKWorkoutConfiguration()
    
    // TODO: isPaired로 관리 가능한지 확인 부탁드려요
    @Published var isWatchAppConnected: Bool = false
    
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
            isWatchAppConnected = true
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
            if session.isReachable {
                self.isWatchAppConnected = true
            }
            print("isWatchAppReachable: \(self.isWatchAppConnected)")
        }
    }
    
    // MARK: - 워치 런치
    func launchWatch() async -> Bool {
        // 비동기적으로 권한 요청
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    // 권한 요청 실패 시 처리
                    self.isWatchAppConnected = false
                    ErrorHandler.handleError(error: error ?? "unknown error")
                    continuation.resume(returning: false) // 실패 시 false 반환
                    return
                }
                
                // 설정 적용
                self.configuration.activityType = .running
                self.configuration.locationType = .outdoor
                
                Task {
                    do {
                        try await self.healthStore.startWatchApp(toHandle: self.configuration)
                        continuation.resume(returning: true) // 성공 시 true 반환
                    } catch {
                        // 오류 처리
                        self.isWatchAppConnected = false
                        ErrorHandler.handleError(error: error)
                        continuation.resume(returning: false) // 실패 시 false 반환
                    }
                }
            }
        }
    }
    
    // MARK: - 워치로 메시지 보내는 부분
    // 1. 곡 선택 후 [제목],[햅틱시퀀스] 보냄 (리스트뷰에서 곡을 선택할 때 작동)
    func sendScoreSelectionToWatch(scoreTitle: String, hapticSequence: [Double]) {
        self.selectedScoreTitle = scoreTitle
        print("워치로 전송 햅틱 : \(hapticSequence)")
        let message: [String: Any] = [
            "scoreTitle": scoreTitle,
            "hapticSequence": hapticSequence
        ]
        
        do {
            try WCSession.default.updateApplicationContext(message)
            self.isWatchAppConnected = true
            print("워치로 곡 선택 메시지 전송 완료: \(message)")
        } catch {
            self.isWatchAppConnected = false
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
        }
    }
    
    // 2. 연습뷰에서 [재생 상태]를 보냄. 재생인 경우 [시작시간] 보냄. (연습뷰에서 재생 관련 버튼 조작시 작동)
    func sendPlayStatusToWatch(status: PlayStatus, startTime: TimeInterval?) {
        // 워치가 연결되어 있는지 확인 (페어링 및 앱 설치 여부)
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else {
            self.isWatchAppConnected = false
            ErrorHandler.handleError(error: "워치가 연결되지 않았거나 앱이 설치되어 있지 않음")
            return
        }
        
        let watchHapticGuide = UserSettingData.shared.watchHapticGuide
        print("------------------------\(watchHapticGuide)")
        var message: [String: Any] = [
            "playStatus": status.rawValue,
            "watchHapticGuide": watchHapticGuide
        ]
        
        if status == .play {
            guard let startTime = startTime else {
                ErrorHandler.handleError(error: "예약 시간이 설정되어 있지 않음")
                return
            }
            // startTime을 메시지 딕셔너리에 직접 추가
            message["startTime"] = startTime
        }
        
        do {
            try WCSession.default.updateApplicationContext(message)
            self.isWatchAppConnected = true
            print("워치로 메시지 전송 완료: \(message)")
        } catch {
            self.isWatchAppConnected = false
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
        }
    }
}
