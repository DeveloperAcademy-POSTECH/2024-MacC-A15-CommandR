//
//  ErrorHandler.swift
//  RhythmTokTok
//
//  Created by 백록담 on 10/9/24.
//

import Foundation

class ErrorHandler {
    static func handleError(fileName: String = #file, functionName: String = #function, lineNumber: Int = #line, error: Error) {
        let file = (fileName as NSString).lastPathComponent
        let errorMessage = error.localizedDescription
        print("Error \(file) \(functionName) : [Line: \(lineNumber)] Failed to \(errorMessage)")
    }
}
