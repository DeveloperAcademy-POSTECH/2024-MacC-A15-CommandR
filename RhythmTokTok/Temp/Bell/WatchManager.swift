//
//  WatchManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/8/24.

import WatchConnectivity
import UIKit

class WatchManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchManager()
    
    @Published var isWatchAppReachable: Bool = false
    
    private override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            ErrorHandler.handleError(errorMessage: "WCSession 지원되지 않음")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("iOS 앱에서 WCSession 활성화 요청")
    }
    
    // MARK: - WCSessionDelegate 메서드
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("iOS 앱에서 WCSession 활성화 완료")
        }
        if let error = error {
            ErrorHandler.handleError(errorMessage: "WCSession 활성화 실패 - \(error.localizedDescription)")
        }
        
        // 상태 변경 알림 전송
        print("activationDidCompleteWith: 상태 변경 알림 전송")
        updateWatchAppReachability(session)
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        updateWatchAppReachability(session)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession 비활성화됨")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
        print("WCSession 다시 활성화 요청")
    }
    
    private func updateWatchAppReachability(_ session: WCSession) {
        DispatchQueue.main.async {
            print("updateWatchAppReachability: isWatchAppReachable = \(session.isReachable)")
            self.isWatchAppReachable = session.isReachable
            NotificationCenter.default.post(name: .watchConnectivityStatusChanged, object: nil)
        }
    }
    
    func sendMessageToWatch(title: String, startTime: Date, vibrationSequence: [Int]) {
        guard WCSession.default.isReachable else {
            print("워치가 연결되지 않음")
            return
        }
        
        // 데이터를 dictionary로 만들고 JSON으로 직렬화
        let dateFormatter = ISO8601DateFormatter()
        let message: [String: Any] = [
            "title": title,
            "startTime": dateFormatter.string(from: startTime),
            "vibrationSequence": vibrationSequence
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: [])
            if let jsonString = String(data: data, encoding: .utf8) {
                // 워치로 메시지 전송
                WCSession.default.sendMessage(["message": jsonString], replyHandler: { response in
                    print("워치로부터의 응답: \(response)")
                }, errorHandler: { error in
                    print("메시지 전송 오류: \(error)")
                })
            }
        } catch {
            print("JSON 직렬화 오류: \(error)")
        }
    }
    
    func sendSampleMessageToWatch() {
         guard WCSession.default.isReachable else {
             ErrorHandler.handleError(errorMessage: "워치가 연결되지 않음")
             return
         }
         
         // 샘플 데이터 생성
         let sampleTitle = "테스트 알림"
         let sampleStartTime = Date()
         let sampleVibrationSequence = [1, 2, 3, 4, 5]
         
         // 데이터를 dictionary로 만들고 JSON으로 직렬화
         let dateFormatter = ISO8601DateFormatter()
         let message: [String: Any] = [
             "title": sampleTitle,
             "startTime": dateFormatter.string(from: sampleStartTime),
             "vibrationSequence": sampleVibrationSequence
         ]
         
         do {
             let data = try JSONSerialization.data(withJSONObject: message, options: [])
             if let jsonString = String(data: data, encoding: .utf8) {
                 // 워치로 메시지 전송
                 WCSession.default.sendMessage(["message": jsonString], replyHandler: { response in
                     print("워치로부터의 응답: \(response)")
                 }, errorHandler: { error in
                     ErrorHandler.handleError(errorMessage: "메시지 전송 오류: \(error.localizedDescription)")
                 })
             }
         } catch {
             ErrorHandler.handleError(errorMessage: "JSON 직렬화 오류: \(error)")
         }
     }
 }
