//
//  WatchManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/8/24.
//
// WatchManager.swift

import WatchConnectivity
import UIKit

// 워치 연결 상태 변경 알림을 위한 Notification 이름 정의
extension Notification.Name {
    static let watchConnectivityStatusChanged = Notification.Name("watchConnectivityStatusChanged")
}

class WatchManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchManager()
    
    private override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            print("Error [WatchManager]: Failed to WCSession 지원되지 않음")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("iOS 앱에서 WCSession 활성화 요청")
    }
    
    // MARK: - WCSessionDelegate 메서드
    
    // 세션 활성화 완료 시 호출
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("iOS 앱에서 WCSession 활성화 완료")
        }
        if let error = error {
            print("Error [WatchManager]: Failed to WCSession 활성화 실패 \(error.localizedDescription)")
        }
        
        // 상태 변경 알림 전송
        NotificationCenter.default.post(name: .watchConnectivityStatusChanged, object: nil)
    }
    
    // 워치 앱의 연결 상태가 변경될 때 호출
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("워치 앱 연결 상태 변경됨: \(session.isReachable)")
        
        // 상태 변경 알림 전송
        NotificationCenter.default.post(name: .watchConnectivityStatusChanged, object: nil)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession 비활성화됨")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
        print("WCSession 다시 활성화 요청")
    }
}
