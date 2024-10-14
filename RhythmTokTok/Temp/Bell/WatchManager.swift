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
}
