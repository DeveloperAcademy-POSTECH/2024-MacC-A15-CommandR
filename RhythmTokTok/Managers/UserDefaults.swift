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
    private let watchHapticGuideKey = "watchHapticGuide"
    private let fontSizeKey = "fontSize"
    private let bpmKey = "bpm"
    
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
    var isHapticGuideOn: Bool {
        get {
            if UserDefaults.standard.object(forKey: watchHapticGuideKey) != nil {
                return UserDefaults.standard.bool(forKey: watchHapticGuideKey)
            } else {
                return true // 기본값 true로 설정
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: watchHapticGuideKey)
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
    
    // BPM 설정 (기본값: 120, 범위: 60 ~ 180)
      var bpm: Int {
          get {
              let storedBPM = UserDefaults.standard.integer(forKey: bpmKey)
              return storedBPM >= 60 && storedBPM <= 180 ? storedBPM : 120 // 기본값 120
          }
          set {
              let clampedBPM = min(max(newValue, 60), 180)
              UserDefaults.standard.set(clampedBPM, forKey: bpmKey)
              NotificationCenter.default.post(name: .bpmChanged, object: nil, userInfo: ["bpm": clampedBPM])
          }
      }
  }
