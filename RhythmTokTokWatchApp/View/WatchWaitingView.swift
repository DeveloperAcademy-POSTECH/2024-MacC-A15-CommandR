//
//  ContentView.swift
//  RhythmTokTokWatchWatchApp
//
//  Created by Byeol Kim on 10/5/24.
//

// ContentView.swift

import SwiftUI

struct WatchWaitingView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    
    var body: some View {
        ZStack {
            Image("BasicBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            if connectivityManager.isSelectedSong {
                WatchPlayView()
            } else {
                VStack(alignment: .leading) {
                    Text("아이폰에서")
                    Text("연습하고 싶은 곡을")
                    Text("선택해 주세요.")
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
            }
        }
    }
}

#Preview {
    WatchWaitingView()
        .environmentObject(ConnectivityManager())
}
