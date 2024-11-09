//
//  RhythmTokTokWatchApp.swift
//  RhythmTokTokWatchApp
//
//  Created by 백록담 on 10/5/24.
//
// RhythmTokTokWatchApp.swift

import SwiftUI

@main
struct RhythmTokTokWatchApp: App {
    @StateObject private var connectivityManager = WatchtoiOSConnectivityManager()
    @StateObject private var logger = Logger.shared
    @Environment(\.scenePhase) private var scenePhase  // 앱의 scenePhase를 가져옴

    var body: some Scene {
        WindowGroup {
            WatchWaitingView()
                .environmentObject(connectivityManager)
                .onAppear {
//                    // 앱이 처음 시작될 때 상태와 시간 출력
//                    let currentTime = Date()
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "HH:mm:ss"
//                    let formattedTime = dateFormatter.string(from: currentTime)
//                    switch scenePhase {
//                    case .active:
//                        logger.watchStatus += "Activate \(formattedTime)"
//                    case .inactive:
//                        logger.watchStatus += "inactive \(formattedTime)"
//                    case .background:
//                        logger.watchStatus += "background \(formattedTime)"
//                    @unknown default:
//                        logger.watchStatus += "@unknown \(formattedTime)"
//                    }
                }
        }
        .onChange(of: scenePhase) { newPhase in
//            // 상태가 변경될 때마다 상태와 시간 출력
//            let currentTime = Date()
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "mm:ss"
//            let formattedTime = dateFormatter.string(from: currentTime)
//
//            switch newPhase {
//            case .active:
//                logger.watchStatus += "Activate \(formattedTime)"
//            case .inactive:
//                logger.watchStatus += "inactive \(formattedTime)"
//            case .background:
//                logger.watchStatus += "background \(formattedTime)"
//            @unknown default:
//                logger.watchStatus += "@unknown \(formattedTime)"
//            }
        }
    }
}
