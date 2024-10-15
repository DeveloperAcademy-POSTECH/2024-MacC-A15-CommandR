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
import Combine

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var isConnected: Bool = false
    
    override init() {
        super.init()
        setupSession()
    }
    
    // 워치 측에서 WCSession 설정
    private func setupSession() {
        guard WCSession.isSupported() else {
            ErrorHandler.handleError(error: "WCSession 지원되지 않음")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("watchOS 앱에서 WCSession 활성화 요청")
    }
    
    // MARK: - WCSessionDelegate 메서드

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if activationState == .activated {
            print("watchOS에서 WCSession 활성화 완료")
            DispatchQueue.main.async {
                self.isConnected = session.isReachable
            }
        }
        if let error = error {
            ErrorHandler.handleError(error: "WCSession 활성화 실패 - \(error.localizedDescription)")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isConnected = session.isReachable
        }
        print("watchOS 앱 연결 상태 변경됨: \(session.isReachable)")
    }
    
    // 아이폰으로부터 메시지를 받았을 때 호출
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let jsonString = message["message"] as? String else {
            ErrorHandler.handleError(error: "메시지 형식 오류")
            return
        }
        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let parsedData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    let title = parsedData["title"] as? String ?? ""
                    let startTimeString = parsedData["startTime"] as? String ?? ""
                    let vibrationSequence = parsedData["vibrationSequence"] as? [Double] ?? []
                    
                    // 시작 시간을 다시 Date로 변환
                    let dateFormatter = ISO8601DateFormatter()
                    let startTime = dateFormatter.date(from: startTimeString)
                    
                    print("워치에서 메시지 수신: 제목 - \(title), 시작 시간 - \(String(describing: startTime)), 진동 시퀀스 - \(vibrationSequence)")
                    
                    // iPhone으로 응답 전송
                    replyHandler(["response": "워치가 메시지를 잘 받았습니다."])
                    
                }
            } catch {
                ErrorHandler.handleError(error: "JSON 파싱 오류: \(error.localizedDescription)")
            }
        }
    }
}
