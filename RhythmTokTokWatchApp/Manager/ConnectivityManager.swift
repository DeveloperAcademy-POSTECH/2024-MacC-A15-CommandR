//
//  WatchSessionManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//

// ConnectivityManager.swift

// ConnectivityManager.swift

import Foundation
import WatchConnectivity
import WatchKit

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var isConnected: Bool = false
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            print("Error [ConnectivityManager]: Failed to WCSession 지원되지 않음")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("watchOS 앱에서 WCSession 활성화 요청")
    }
    
    // MARK: - WCSessionDelegate 메서드
    
    // 세션 활성화 완료 시 호출
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("watchOS 앱에서 WCSession 활성화 완료")
            DispatchQueue.main.async {
                self.isConnected = session.isReachable
            }
        }
        if let error = error {
            print("Error [ConnectivityManager]: Failed to watchOS 앱에서 WCSession 활성화 실패: \(error.localizedDescription)")
            
        }
    }
    
    // 워치 앱의 연결 상태가 변경될 때 호출
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("watchOS 앱 연결 상태 변경됨: \(session.isReachable)")
        DispatchQueue.main.async {
            self.isConnected = session.isReachable
        }
    }
}
