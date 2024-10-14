//
//  WatchSessionManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//
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
            ErrorHandler.handleError(errorMessage: "WCSession 지원되지 않음")
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
            ErrorHandler.handleError(errorMessage: "Failed to watchOS 앱에서 WCSession 활성화 실패: \(error.localizedDescription)")
        }
    }
    
    // 워치 앱의 연결 상태가 변경될 때 호출
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("watchOS 앱 연결 상태 변경됨: \(session.isReachable)")
        DispatchQueue.main.async {
            self.isConnected = session.isReachable
        }
    }
    
    // 아이폰으로부터 메시지를 받았을 때 호출
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let jsonString = message["message"] as? String else {
            ErrorHandler.handleError(errorMessage: "메시지 형식 오류")
            return
        }
        
        // JSON 파싱
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let parsedData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    let title = parsedData["title"] as? String ?? ""
                    let startTimeString = parsedData["startTime"] as? String ?? ""
                    let vibrationSequence = parsedData["vibrationSequence"] as? [Int] ?? []
                    
                    // 시작 시간을 다시 Date로 변환
                    let dateFormatter = ISO8601DateFormatter()
                    let startTime = dateFormatter.date(from: startTimeString)
                    
                    print("제목: \(title), 시작 시간: \(String(describing: startTime)), 진동 시퀀스: \(vibrationSequence)")
                    
                    // 아이폰에 성공 메시지 전송
                    session.sendMessage(["response": "메시지를 잘 받았습니다"], replyHandler: nil, errorHandler: { error in
                        ErrorHandler.handleError(errorMessage: "응답 메시지 전송 오류: \(error.localizedDescription)")
                    })
                }
            } catch {
                ErrorHandler.handleError(errorMessage: "JSON 파싱 오류: \(error.localizedDescription)")
            }
        }
    }
}
