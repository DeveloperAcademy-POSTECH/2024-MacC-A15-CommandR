//
//  ContentView.swift
//  RhythmTokTokWatchWatchApp
//
//  Created by 백록담 on 10/5/24.
//

// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(.title)
            
            // 워치 앱 상태 표시
            Text(connectivityManager.isConnected ? "워치 앱 켜짐" : "워치 앱 꺼짐")
                .font(.title2)
                .foregroundColor(connectivityManager.isConnected ? .green : .red)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
