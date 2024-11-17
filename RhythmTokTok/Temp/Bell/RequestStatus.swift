//
//  RequestStatus.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import Foundation

enum RequestStatus {
    case downloaded
    case inProgress
    case scoreReady
    case deleted
    case cancelled
    
    var headerText: String {
        switch self {
        case .downloaded, .deleted, .cancelled:
            return "이전 요청 기록"
        case .inProgress:
            return "준비 중인 음악"
        case .scoreReady:
            return "완성된 음악"
        }
    }
}
