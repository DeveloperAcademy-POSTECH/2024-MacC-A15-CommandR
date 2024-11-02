//
//  SoundSetting.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 10/11/24.
//

import Foundation

enum SoundSetting: String, Codable {
    case voice = "계이름으로 듣기"
    case melody = "멜로디로 듣기"
    case beat = "박자만 듣기"
    case mute = "소리 없음"
}
