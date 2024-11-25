//
//  RequestStatus.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import Foundation

enum RequestStatus: Int {
    case inProgress = 0
    case scoreReady = 1
    case downloaded = 2
    case deleted = 3
    case cancelled = 11
    case errorOccurred = 22
    
    init?(rawValue: Int) {
           switch rawValue {
           case 0:
               self = .inProgress
           case 1:
               self = .scoreReady
           case 2:
               self = .downloaded
           case 3:
               self = .deleted
           case 11:
               self = .cancelled
           case 22, 23, 24, 25:
               self = .errorOccurred
           default:
               ErrorHandler.handleError(error: "알수없는 상태: \(rawValue)")
               return nil
           }
       }
    
    var headerText: String {
        switch self {
        case .inProgress:
            return "준비 중인 음악"
        case .scoreReady:
            return "완성된 음악"
        case .errorOccurred:
            return "확인이 필요한 악보"
        case .downloaded, .deleted, .cancelled:
            return ""
        }
    }
}
