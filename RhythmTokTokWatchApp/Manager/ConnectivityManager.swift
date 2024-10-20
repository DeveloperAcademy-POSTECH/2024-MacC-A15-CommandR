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
    @Published var isSelectedScore: Bool = false
    @Published var selectedScoreTitle: String = ""
    @Published var playStatus: String = "준비"
    @Published var hapticSequence: [Double] = []
    
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
    
    // MARK: - iPhone으로부터 Application Context 수신
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 1. 곡 선택 후 [제목], [햅틱 시퀀스] 받음
            if let scoreTitle = applicationContext["scoreTitle"] as? String,
               let hapticSequence = applicationContext["hapticSequence"] as? [Double] {
                self.selectedScoreTitle = scoreTitle
                self.hapticSequence = hapticSequence
                self.isSelectedScore = !scoreTitle.isEmpty
                print("곡 선택 완료, 곡 제목: \(scoreTitle)")
            }
            // 2. 연습뷰에서 [재생 상태]를 받음. 재생인 경우 [시작 시간] 받음.
            else if let playStatusString = applicationContext["playStatus"] as? String,
                    let playStatus = PlayStatus(rawValue: playStatusString) {
                self.playStatus = playStatus.rawValue
                print("재생 상태 업데이트: \(playStatus.rawValue)")
                
                switch playStatus {
                case .play:
                    if let startTime = applicationContext["startTime"] as? TimeInterval {
                        print("시작 시간 수신: \(startTime)")
                        // 햅틱 시퀀스 시작 예약
                        self.hapticManager.startHaptic(beatTime: self.hapticSequence, startTimeInterval: startTime)
                    } else {
                        ErrorHandler.handleError(error: "시작 시간 누락")
                    }
                case .pause, .stop:
                    self.hapticManager.stopHaptic()
                }
            } else {
                ErrorHandler.handleError(error: "알 수 없는 재생 상태")
            }
        }
    }
}
