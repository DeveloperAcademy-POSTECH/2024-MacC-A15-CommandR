//
//  WatchSessionManager.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//
// ConnectivityManager.swift

import Foundation
import WatchConnectivity
import Combine

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var isConnected: Bool = false
    @Published var isSelectedSong: Bool = false
    @Published var selectedSongTitle: String = ""
    @Published var playStatus: String = "준비"
    
    override init() {
        super.init()
        setupSession()
    }
    
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
            print("워치에서 WCSession 활성화 완료")
            DispatchQueue.main.async {
                self.isConnected = session.isReachable
            }
        }
        if let error = error {
            ErrorHandler.handleError(error: "WCSession 활성화 실패 - \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("워치에서 메시지 수신: \(message)")
        
        // 1. 곡 선택 메시지 (리스트뷰에서 곡을 선택했을 때 작동)
        if let isSelectedSong = message["isSelectedSong"] as? Bool, let songTitle = message["songTitle"] as? String {
            DispatchQueue.main.async {
                self.isSelectedSong = isSelectedSong
                self.selectedSongTitle = songTitle
                print("곡 선택 상태: \(isSelectedSong), 곡 제목: \(songTitle)")
            }
            replyHandler(["response": "곡 선택 수신 완료"])
        }
        
        // 2. 재생 상태 메시지 (연습뷰에서 재생 관련 버튼을 조작했을 때 작동)
        else if let playStatus = message["playStatus"] as? String {
            DispatchQueue.main.async {
                self.playStatus = playStatus
                print("재생 상태 업데이트: \(playStatus)")
            }
            
            // 추가 데이터 처리
            if playStatus == "play", let additionalDataString = message["additionalData"] as? String {
                if let additionalData = convertFromJSONString(jsonString: additionalDataString) {
                    // 추가 데이터에서 필요한 정보를 추출
                    if let title = additionalData["title"] as? String,
                       let startTimeString = additionalData["startTime"] as? String,
                       let vibrationSequence = additionalData["vibrationSequence"] as? [Double] {
                        let dateFormatter = ISO8601DateFormatter()
                        if let startTime = dateFormatter.date(from: startTimeString) {

                            print("추가 데이터 수신 - 제목: \(title), 시작시간: \(startTime), 진동시퀀스: \(vibrationSequence)")
                            // 여기서 원하는 로직을 구현하세요.
                        } else {
                            ErrorHandler.handleError(error: "시작 시간 변환 실패")
                        }
                    }
                } else {
                    ErrorHandler.handleError(error: "JSON 파싱 실패")
                }
            }
            replyHandler(["response": "재생 상태 수신 완료"])
        } else {
            ErrorHandler.handleError(error: "알 수 없는 메시지 형식")
            replyHandler(["response": "메시지 형식 오류"])
        }
    }
    
    // JSON 문자열을 딕셔너리로 변환하는 유틸리티 메서드 추가
    private func convertFromJSONString(jsonString: String) -> [String: Any]? {
        if let jsonData = jsonString.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
           let dictionary = jsonObject as? [String: Any] {
            return dictionary
        }
        return nil
    }
}
