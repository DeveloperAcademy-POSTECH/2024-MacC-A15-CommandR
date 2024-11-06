//
//  ErrorHandler.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/9/24.
//

import Foundation

class ErrorHandler {
    /// 통합 에러 핸들러
    static func handleError(fileName: String = #file,
                            functionName: String = #function, lineNumber: Int = #line, error: Any) {
        let file = (fileName as NSString).lastPathComponent
        
        // errorMessage 변수를 먼저 정의
        let errorMessage: String
        
        // Error 타입인지 확인하여 각각 처리
        if let error = error as? Error {
            errorMessage = error.localizedDescription
        } else {
            errorMessage = String(describing: error)
        }
        
        // errorMessage를 print 구문에서 사용
        print("Error \(file) \(functionName) : [Line: \(lineNumber)] Failed to \(errorMessage)")
    }
    
}
