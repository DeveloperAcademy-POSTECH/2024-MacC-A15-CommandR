//
//  Logger.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 11/3/24.
//

import SwiftUI

// MARK: 실행 시간을 확인하기 위한 객체
class Logger: ObservableObject {
    static let shared = Logger() // 싱글톤 인스턴스 생성
    @Published var watchScheduledTime: String =  "대기중"
    @Published var watchHapticTime: String =  "대기중"
    @Published var activatedSession: String = "0"

    @Published var iosScheduledTime: String =  "대기중"
    @Published var iosStartTime: String =  "대기중"

    private let dateFormatter: DateFormatter

    private init(dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS") { // private으로 설정하여 외부에서 초기화하지 못하게 함
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
    }

    func log(_ message: String) {
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        print("*\(formattedDate)* \(message)")
        iosScheduledTime = formattedDate
    }
    
    func watchLog(_ message: String) {
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        print("*\(formattedDate)* \(message)")
        watchHapticTime = formattedDate
    }
    
    func logTimeInterval(_ timeInterval: TimeInterval, message: String) {
        let referenceDate = Date(timeIntervalSince1970: 0)
        let date = referenceDate.addingTimeInterval(timeInterval)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let formattedTime = timeFormatter.string(from: date)
        
        log("\(message) \(formattedTime)")
        iosStartTime = formattedTime
    }
    
    func watchLogTimeInterval(_ timeInterval: TimeInterval, message: String) {
        let referenceDate = Date(timeIntervalSince1970: 0)
        let date = referenceDate.addingTimeInterval(timeInterval)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let formattedTime = timeFormatter.string(from: date)
        
        log("\(message) \(formattedTime)")
        watchScheduledTime = formattedTime
    }
}
