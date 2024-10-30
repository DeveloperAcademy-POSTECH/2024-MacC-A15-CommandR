//
//  Notification.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//

import Foundation

extension Notification.Name {
    static let watchConnectivityStatusChanged = Notification.Name("watchConnectivityStatusChanged")
    static let fontSizeChanged = Notification.Name("fontSizeChanged")
    static let bpmChanged = Notification.Name("bpmChanged") // BPM 변경 알림 추가
    static let soundSettingDidChange = Notification.Name("soundSettingDidChange")
}
