//
//  WatchManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/8/24.

import HealthKit
import UIKit
import WatchConnectivity

class WatchManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchManager()
    // 아래 곡 제목에 실제 곡 제목을 넣어주세용
    var selectedSongTitle: String?
    // 런치 용도
    let healthStore = HKHealthStore()
    let allTypes = Set([HKObjectType.workoutType()])
    let configuration = HKWorkoutConfiguration()
    
    // TODO: isPaired로 관리 가능한지 확인 부탁드려요
    @Published var isWatchAppReachable: Bool = false
    
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
        print("WCSession 비활성화됨")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession 비활성화됨 - 다시 활성화 준비")
        WCSession.default.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        updateWatchAppReachability(session)
    }
    
    private func updateWatchAppReachability(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchAppReachable = session.isReachable
            print("isWatchAppReachable: \(self.isWatchAppReachable)")
        }
    }
    
    // MARK: - 워치 런치
    func launchWatch() async -> Bool {
        // 비동기적으로 권한 요청
        return await withCheckedContinuation { continuation in
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    // 권한 요청 실패 시 처리
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
                        ErrorHandler.handleError(error: error)
                        continuation.resume(returning: false) // 실패 시 false 반환
                    }
                }
            }
        }
    }

    // MARK: - 워치로 메시지 보내는 부분
    // 1. 곡 선택 시 워치로 메시지 전송 (리스트뷰에서 곡을 선택할 때 작동)
    func sendSongSelectionToWatch(songTitle: String, hapticSequence: [Double]) {
        self.selectedSongTitle = songTitle
        // TODO: 워치가 백그라운드일 때 메시지 받아서 업데이트 할 수 있게 updateApplicationContext로 전달하게 만들어야됨, 기존 play,pause,stop등을 updateApplicationContext로 만들고 watch활성화 여부에 맞춰서 하는게 좋을 것 같음
        let message: [String: Any] = [
            "songTitle": songTitle,
            "hapticSequence": hapticSequence
        ]
        
        do {
            try WCSession.default.updateApplicationContext(message)
        } catch {
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
        }
        
//        WCSession.default.sendMessage(message, replyHandler: { response in
//            if let responseMessage = response["response"] as? String {
//                print("워치로부터 응답 받음: \(responseMessage)")
//            } else {
//                ErrorHandler.handleError(error: "응답 메시지 형식 오류")
//            }
//        }, errorHandler: { error in
//            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
//        })
    }
    
    // 2. 재생 상태 변경 시 워치로 메시지 전송 (연습뷰에서 재생 관련 버튼 조작시 작동)
    func sendPlayStatusToWatch(status: String, startTime: TimeInterval?) {
        guard WCSession.default.isReachable else {
            ErrorHandler.handleError(error: "워치가 연결되지 않았음")
            return
        }
        
        var message: [String: Any] = [
            "playStatus": status
        ]
        
        if status == "play" {
            guard let startTime = startTime else {
                ErrorHandler.handleError(error: "예약 시간이 설정되어 있지 않음")
                return
            }
            // startTime을 메시지 딕셔너리에 직접 추가
            message["startTime"] = startTime
        }
        
        WCSession.default.sendMessage(message, replyHandler: { response in
            if let responseMessage = response["response"] as? String {
                print("워치로부터 응답 받음: \(responseMessage)")
            } else {
                ErrorHandler.handleError(error: "응답 메시지 형식 오류")
            }
        }, errorHandler: { error in
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
        })
    }
    // JSON 문자열로 변환하는 유틸리티 메서드 추가
    private func convertToJSONString(data: [String: Any]) -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
    
    // iPhone이 워치로부터 메시지를 받았을 때 호출되는 메서드
    // 현재는 사용되지 않지만 추후 워치로부터 메세지를 받을 때 사용할 것.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any],
                 replyHandler: @escaping ([String: Any]) -> Void) {
        print("iPhone이 워치로부터 메시지 수신: \(message)")
        replyHandler(["response": "iPhone이 메시지를 잘 받았습니다."])
    }
}
