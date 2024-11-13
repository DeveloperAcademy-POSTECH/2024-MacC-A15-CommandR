//
//  SoundSetting.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/11/24.
//

import Foundation

enum SoundSetting: String, Codable {
    case voice
    case melody
    case beat
    case mute
    
    static var `default`: SoundSetting {
        return .melody // 기본값으로 .voice 설정
    }
}
