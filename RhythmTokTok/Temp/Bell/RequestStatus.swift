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
    case errorOccurred
    
    var headerText: String {
        switch self {
        case .inProgress:
            return "준비 중인 음악"
        case .scoreReady:
            return "완성된 음악"
        case .errorOccurred:
            return "다시 요청이 필요한 음악"
        case .downloaded, .deleted, .cancelled:
            return ""
        }
    }
}
