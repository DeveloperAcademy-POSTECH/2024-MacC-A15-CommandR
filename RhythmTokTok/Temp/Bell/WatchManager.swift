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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("iPhone에서 WCSession 활성화 완료")
        }
        if let error = error {
            ErrorHandler.handleError(errorMessage: "WCSession 활성화 실패 - \(error.localizedDescription)")
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
    
    // MARK: - 워치로 메시지 보내는 부분
    
    // 1. 곡 선택 시 워치로 메시지 전송
    func sendSongSelectionToWatch(isSelectedSong: Bool, songTitle: String) {
        guard WCSession.default.isReachable else {
            print("워치가 연결되지 않음")
            return
        }
        
        let message: [String: Any] = [
            "isSelectedSong": isSelectedSong,
            "songTitle": songTitle
        ]
        
        WCSession.default.sendMessage(message, replyHandler: { response in
            if let responseMessage = response["response"] as? String {
                print("워치로부터 응답 받음: \(responseMessage)")
            } else {
                ErrorHandler.handleError(errorMessage: "응답 메시지 형식 오류")
            }
        }, errorHandler: { error in
            ErrorHandler.handleError(errorMessage: "메시지 전송 오류: \(error.localizedDescription)")
        })
    }
    
    // 2. 재생 상태 변경 시 워치로 메시지 전송
    func sendPlayStatusToWatch(status: String) {
        guard WCSession.default.isReachable else {
            print("워치가 연결되지 않음")
            return
        }
        
        let message: [String: Any] = [
            "playStatus": status
        ]
        
        WCSession.default.sendMessage(message, replyHandler: { response in
            if let responseMessage = response["response"] as? String {
                print("워치로부터 응답 받음: \(responseMessage)")
            } else {
                ErrorHandler.handleError(errorMessage: "응답 메시지 형식 오류")
            }
        }, errorHandler: { error in
            ErrorHandler.handleError(errorMessage: "메시지 전송 오류: \(error.localizedDescription)")
        })
    }
    
    // iPhone이 워치로부터 메시지를 받았을 때 호출되는 메서드
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("iPhone이 워치로부터 메시지 수신: \(message)")
        replyHandler(["response": "iPhone이 메시지를 잘 받았습니다."])
    }
}
