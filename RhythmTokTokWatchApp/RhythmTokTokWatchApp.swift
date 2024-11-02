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
            WatchWaitingView()
                .environmentObject(connectivityManager)
        }
    }
}
