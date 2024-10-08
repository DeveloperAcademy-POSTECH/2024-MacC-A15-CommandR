//
//  Pitch.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/6/24.
//

import Foundation

enum Pitch: String {
    case C4, D4, E4, F4, G4, A4, B4, C5
    case D1, E1, F1, G1, A1, B1
    case C2, D2, E2, F2, G2, A2, B2
    case C3, D3, E3, F3, G3, A3, B3
    case D5, E5, F5, G5, A5, B5
    case silence // 무음 처리를 위한 추가 케이스

    // 음계에 해당하는 파일명
    var fileName: String {
        switch self {
        case .C4, .C2, .C3: return "speechDo"
        case .D4, .D1, .D2, .D3, .D5: return "speechRe"
        case .E4, .E1, .E2, .E3, .E5: return "speechMe"
        case .F4, .F1, .F2, .F3, .F5: return "speechPa"
        case .G4, .G1, .G2, .G3, .G5: return "speechSol"
        case .A4, .A1, .A2, .A3, .A5: return "speechRa"
        case .B4, .B1, .B2, .B3, .B5: return "speechSi"
        case .C5: return "speechDo"
        case .silence: return "silence"
        }
    }
    
    // 음계에 해당하는 파일 URL
    var fileURL: URL? {
        return Bundle.main.url(forResource: fileName, withExtension: "mp3")
    }
}
