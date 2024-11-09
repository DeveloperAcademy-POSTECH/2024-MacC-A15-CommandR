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
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                print("활성화 상태")
                connectivityManager.hapticManager.startExtendedSession()
            case .background, .inactive:
                print("활성화 상태아님")
            @unknown default:
                print("활성화 상태아님")
            }
        }
    }
}
