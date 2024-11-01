//
//  WatchManage_Ex.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/29/24.
//
import UIKit
import WatchConnectivity

extension IOStoWatchConnectivityManager {
    // 마디 점프 요청
    func sendUpdateStatusWithHapticSequence(scoreTitle: String, hapticSequence: [Double], status: PlayStatus, startTime: TimeInterval) {
        self.selectedScoreTitle = scoreTitle
        let watchHapticGuide = UserSettingData.shared.isHapticGuideOn

        let message: [String: Any] = [
            "scoreTitle": scoreTitle,
            "hapticSequence": hapticSequence,
            "playStatus": status.rawValue,
            "watchHapticGuide": watchHapticGuide,
            "startTime": startTime
        ]
        
        do {
            try WCSession.default.updateApplicationContext(message)
            self.isWatchAppConnected = true
            print("워치로 곡 선택 메시지 전송 완료: \(message)")
        } catch {
            self.isWatchAppConnected = false
            ErrorHandler.handleError(error: "메시지 전송 오류: \(error.localizedDescription)")
        }
    }
}
