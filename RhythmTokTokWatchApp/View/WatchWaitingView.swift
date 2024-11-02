//
//  ContentView.swift
//  RhythmTokTokWatchWatchApp
//
//  Created by Byeol Kim on 10/5/24.
//

// ContentView.swift

import SwiftUI

struct WatchWaitingView: View {
    @EnvironmentObject var connectivityManager: WatchtoiOSConnectivityManager
    
    var body: some View {
        ZStack {
            Image("BasicBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            if connectivityManager.isSelectedScore {
                WatchPlayView()
            } else {
                Text("아이폰에서\n연습하고 싶은 곡을\n선택해 주세요.")
                    .multilineTextAlignment(.leading)
                    .font(Font.custom("Pretendard-Bold", size: 20))
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

#Preview {
    WatchWaitingView()
        .environmentObject(WatchtoiOSConnectivityManager())
}
