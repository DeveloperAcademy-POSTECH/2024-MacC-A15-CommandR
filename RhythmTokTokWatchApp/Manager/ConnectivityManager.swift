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
    // 햅틱 관리용 매니저
    private var hapticManager = HapticScheduleManager()
    @Published var isConnected: Bool = false
    @Published var isSelectedSong: Bool = false
    @Published var selectedSongTitle: String = ""
    @Published var playStatus: String = "준비"
    @Published var hapticSequence: [Double] = [] // hapticSequence

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

    // MARK: - 백그라운드에서 동작 로직
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        // 1. 곡 선택 메시지 처리
        if let songTitle = applicationContext["songTitle"] as? String,
           let hapticSequence = applicationContext["hapticSequence"] as? [Double] {
            DispatchQueue.main.async {
                self.selectedSongTitle = songTitle
                self.hapticSequence = hapticSequence
                self.isSelectedSong = !songTitle.isEmpty
                print("곡 선택 완료, 곡 제목: \(songTitle)")
            }
        }
        // 2. 재생 상태 메시지 처리
        else if let playStatus = applicationContext["playStatus"] as? String {
            DispatchQueue.main.async {
                self.playStatus = playStatus
                print("재생 상태 업데이트: \(playStatus)")
            }

            if playStatus == "play" {
                if let startTime = applicationContext["startTime"] as? TimeInterval {
                    print("시작 시간 수신: \(startTime)")
                    // 햅틱 시퀀스 시작 예약
                    hapticManager.starHaptic(beatTime: hapticSequence, startTimeInterval: startTime)
                } else {
                    ErrorHandler.handleError(error: "시작 시간 누락")
                }
            } else if playStatus == "pause" {
                hapticManager.stopHaptic()
            } else if playStatus == "stop" {
                hapticManager.stopHaptic()
            }
        } else {
            ErrorHandler.handleError(error: "알 수 없는 메시지 형식")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any],
                 replyHandler: @escaping ([String: Any]) -> Void) {
        // 1. 곡 선택 메시지 처리
        if let songTitle = message["songTitle"] as? String,
           let hapticSequence = message["hapticSequence"] as? [Double] {
            DispatchQueue.main.async {
                self.selectedSongTitle = songTitle
                self.hapticSequence = hapticSequence
                self.isSelectedSong = !songTitle.isEmpty
                print("곡 선택 완료, 곡 제목: \(songTitle)")
            }
            replyHandler(["response": "곡 선택 수신 완료"])
        }
        // 2. 재생 상태 메시지 처리
        else if let playStatus = message["playStatus"] as? String {
            DispatchQueue.main.async {
                self.playStatus = playStatus
                print("재생 상태 업데이트: \(playStatus)")
            }

            if playStatus == "play" {
                if let startTime = message["startTime"] as? TimeInterval {
                    print("시작 시간 수신: \(startTime)")
                    // 햅틱 시퀀스 시작 예약
                    hapticManager.starHaptic(beatTime: hapticSequence, startTimeInterval: startTime)
                } else {
                    ErrorHandler.handleError(error: "시작 시간 누락")
                }
            } else if playStatus == "pause" {
                hapticManager.stopHaptic()
            } else if playStatus == "stop" {
                hapticManager.stopHaptic()
            }
            replyHandler(["response": "재생 상태 수신 완료"])
        } else {
            ErrorHandler.handleError(error: "알 수 없는 메시지 형식")
            replyHandler(["response": "메시지 형식 오류"])
        }
    }
}
