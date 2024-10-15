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
    @Published var playStatus: String = "준비" // 기본 상태는 "준비"
    
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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("워치에서 WCSession 활성화 완료")
            DispatchQueue.main.async {
                self.isConnected = session.isReachable
            }
        }
        if let error = error {
            ErrorHandler.handleError(errorMessage: "WCSession 활성화 실패 - \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("워치에서 메시지 수신: \(message)") // 로그 추가
        
        // 1. 곡 선택 메시지 처리
        if let isSelectedSong = message["isSelectedSong"] as? Bool, let songTitle = message["songTitle"] as? String {
            DispatchQueue.main.async {
                self.isSelectedSong = isSelectedSong
                self.selectedSongTitle = songTitle
                print("곡 선택 상태: \(isSelectedSong), 곡 제목: \(songTitle)")
            }
            replyHandler(["response": "곡 선택 수신 완료"])
        }
        // 2. 재생 상태 메시지 처리
        else if let playStatus = message["playStatus"] as? String {
            DispatchQueue.main.async {
                self.playStatus = playStatus
                print("재생 상태 업데이트: \(playStatus)")
            }
            replyHandler(["response": "재생 상태 수신 완료"])
        } else {
            ErrorHandler.handleError(errorMessage: "알 수 없는 메시지 형식")
            replyHandler(["response": "메시지 형식 오류"])
        }
    }
}
