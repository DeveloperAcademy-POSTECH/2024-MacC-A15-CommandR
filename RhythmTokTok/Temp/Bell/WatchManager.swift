//
//  WatchManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/8/24.

import WatchConnectivity
import UIKit

class WatchManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchManager()
    
    // 상태 확인을 위한 변수
    @Published var isWatchAppReachable: Bool = false
    
    private override init() {
        super.init()
        setupSession()
    }
    
    // WCSession 설정
    private func setupSession() {
        guard WCSession.isSupported() else {
            ErrorHandler.handleError(errorMessage: "WCSession 지원되지 않음")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("iPhone 앱에서 WCSession 활성화 요청")
    }
    
    // MARK: - WCSessionDelegate 메서드
    
    // 세션 활성화 완료 후 호출 (필수 메서드)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("iPhone에서 WCSession 활성화 완료")
        }
        if let error = error {
            ErrorHandler.handleError(errorMessage: "WCSession 활성화 실패 - \(error.localizedDescription)")
        }
        updateWatchAppReachability(session)
    }
    
    // 세션이 비활성화될 때 호출 (필수 메서드)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession 비활성화됨")
    }
    
    // 세션이 비활성화된 후 다시 활성화할 준비가 될 때 호출 (필수 메서드)
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession 비활성화됨 - 다시 활성화 준비")
        WCSession.default.activate() // 다시 활성화 요청
    }
    
    // 세션의 연결 상태가 변경되었을 때 호출
    func sessionReachabilityDidChange(_ session: WCSession) {
        updateWatchAppReachability(session)
    }
    
    private func updateWatchAppReachability(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchAppReachable = session.isReachable
            print("isWatchAppReachable: \(self.isWatchAppReachable)")
        }
    }
    
    //MARK: - 워치로 메세지 보내는 부분 시작
    
    // iPhone -> Watch로 메시지 전송
    func sendMessageToWatch(title: String, startTime: Date, vibrationSequence: [Double]) {
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
                    // 워치로부터 응답 수신
                    if let responseMessage = response["response"] as? String {
                        print("워치로부터 응답 받음: \(responseMessage)")
                    } else {
                        ErrorHandler.handleError(errorMessage: "응답 메시지 형식 오류")
                    }
                }, errorHandler: { error in
                    ErrorHandler.handleError(errorMessage: "메시지 전송 오류: \(error.localizedDescription)")
                })
            }
        } catch {
            ErrorHandler.handleError(errorMessage: "JSON 직렬화 오류: \(error.localizedDescription)")
        }
    }
    
    // 샘플 메시지 전송 (테스트용)
    func sendSampleMessageToWatch() {
        let sampleTitle = "테스트 알림"
        let sampleStartTime = Date()
        let sampleVibrationSequence = [0.5, 1.0]
        
        sendMessageToWatch(title: sampleTitle, startTime: sampleStartTime, vibrationSequence: sampleVibrationSequence)
    }
    
    // iPhone이 워치로부터 메시지를 받았을 때 호출되는 메서드.
    // 현재는 쓰지 않지만 추후 워치에서 아이폰으로 메세지 전송할 때 쓰는 메서드.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("iPhone이 워치로부터 메시지 수신: \(message)")
        replyHandler(["response": "iPhone이 메시지를 잘 받았습니다."])
    }
}
