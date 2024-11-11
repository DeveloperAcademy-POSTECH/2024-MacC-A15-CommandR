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
    
    var headerText: String {
        switch self {
        case .downloaded:
            return "완료된 악보"
        case .inProgress:
            return "준비 중인 악보"
        case .scoreReady:
            return "완성된 악보"
        }
    }
}