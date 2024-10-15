//
//  UserDefault.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/9/24.
//

import Foundation

class UserSettingData {
    
    static let shared = UserSettingData()
    
    private let soundSettingKey = "soundSetting"
    private let watchVibrationGuideKey = "watchVibrationGuide"
    private let fontSizeKey = "fontSize"
    
    private init() {}
    
    // 소리 설정
    var soundSetting: SoundSetting {
        get {
            if let value = UserDefaults.standard.string(forKey: soundSettingKey),
               let setting = SoundSetting(rawValue: value) {
                return setting
            }
            return .voice // 기본값
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: soundSettingKey)
        }
    }
    
    // Watch 진동 가이드 설정
    var watchVibrationGuide: Bool {
        get {
            return UserDefaults.standard.bool(forKey: watchVibrationGuideKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: watchVibrationGuideKey)
        }
    }
    
    // 글자 크기 설정 (1: 작은, 2: 보통, 3: 큼, 4: 매우 큼)
    var fontSize: Int {
        get {
            let size = UserDefaults.standard.integer(forKey: fontSizeKey)
            return size >= 1 && size <= 4 ? size : 2 // 기본값 보통
        }
        set {
            let clampedValue = min(max(newValue, 1), 4)
            UserDefaults.standard.set(clampedValue, forKey: fontSizeKey)
            // 글자 크기 변경 시 알림 전송
            NotificationCenter.default.post(name: .fontSizeChanged, object: nil, userInfo: ["fontSize": clampedValue])
        }
    }
}
