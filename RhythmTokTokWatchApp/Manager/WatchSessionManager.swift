//
//  WatchSessionManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//

import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = WatchSessionManager()

    override init() {
        super.init()
        setupSession()
    }

    func setupSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("워치 앱 WCSession 활성화 요청")
        }
    }

    // MARK: - WCSessionDelegate 메서드

    // 세션 활성화 완료 시 호출 (필수 메서드)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("워치 앱 WCSession 활성화 완료")
        }
        if let error = error {
            print("워치 앱 WCSession 활성화 실패: \(error.localizedDescription)")
        }
    }

    // 워치앱에서는 `sessionDidBecomeInactive(_:)`와 `sessionDidDeactivate(_:)`를 구현할 필요가 없습니다.
    // 해당 메서드들은 watchOS에서 사용 불가능합니다.

    // 필요한 경우 추가 메서드 구현
}
