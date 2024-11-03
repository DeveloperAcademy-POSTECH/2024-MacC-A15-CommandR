//
//  BPMLabel.swift
//  RhythmTokTok
//
//  Created by Kyuhee hong on 11/2/24.
//

struct BPMDescription {
    static func description(for bpm: Int) -> String {
        switch bpm {
        case 0..<60:
            return "매우 느리게"
        case 60..<80:
            return "느리게"
        case 80..<100:
            return "조금 느리게"
        case 100..<120:
            return "보통"
        case 120..<140:
            return "조금 빠르게"
        case 140..<160:
            return "빠르게"
        case 160...:
            return "매우 빠르게"
        default:
            return "알 수 없음"
        }
    }
}
