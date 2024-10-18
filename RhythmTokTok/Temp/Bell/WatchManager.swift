//
//  WatchManager.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/8/24.

import WatchConnectivity
import UIKit

class WatchManager: NSObject, WCSessionDelegate {
    
    static let shared = WatchManager()
    // 아래 곡 제목에 실제 곡 제목을 넣어주세용
    var selectedSongTitle: String?
    
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
    
    // MARK: - 워치로 메시지 보내는 부분
    
    // 1. 곡 선택 시 워치로 메시지 전송 (리스트뷰에서 곡을 선택할 때 작동)
    func sendSongSelectionToWatch(isSelectedSong: Bool, songTitle: String) {
        guard WCSession.default.isReachable else {
            print("워치가 연결되지 않음")
            return
        }
        
        self.selectedSongTitle = songTitle
        
        let message: [String: Any] = [
            "isSelectedSong": isSelectedSong,
            "songTitle": songTitle
        ]
        
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
    
    // 2. 재생 상태 변경 시 워치로 메시지 전송 (연습뷰에서 재생 관련 버튼 조작시 작동)
    func sendPlayStatusToWatch(status: String) {
        guard WCSession.default.isReachable else {
            print("워치가 연결되지 않음")
            return
        }
        
        var message: [String: Any] = [
            "playStatus": status
        ]
        
        if status == "play" {
            // selectedSongTitle이 nil인지 확인하고 사용
            let title = selectedSongTitle ?? "제목 없음"
            let startTime = Date()
            let vibrationSequence: [Double] = [0.5, 1.0, 0.5]
            
            // Date를 문자열로 변환 (ISO8601 형식)
            let dateFormatter = ISO8601DateFormatter()
            let startTimeString = dateFormatter.string(from: startTime)
            
            // 추가 데이터를 딕셔너리로 구성
            let additionalData: [String: Any] = [
                "title": title,
                "startTime": startTimeString,
                "vibrationSequence": vibrationSequence
            ]
            
            // 딕셔너리를 JSON 문자열로 변환
            if let additionalDataString = convertToJSONString(data: additionalData) {
                message["additionalData"] = additionalDataString
            } else {
                ErrorHandler.handleError(error: "추가 데이터 변환 실패")
            }
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
