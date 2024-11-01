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
    
    var body: some Scene {
        WindowGroup {
            TabView {
                WatchWaitingView()
                    .environmentObject(connectivityManager)
                    .tabItem {
                        Label("워치연결확인", systemImage: "applewatch")
                    }
                PlayHapticView()
                    .tabItem {
                        Label("햅틱실행", systemImage: "wave.3.right")
                    }
            }
        }
    }
}
