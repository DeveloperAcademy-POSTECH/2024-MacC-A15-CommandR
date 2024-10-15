//
//  WatchPlayView.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 10/15/24.
//
import SwiftUI

struct WatchPlayView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    
    private var songStatusText: String {
        switch connectivityManager.playStatus {
        case "ready", "stop", "":
            return "준비"
        case "play":
            return "재생중"
        case "pause":
            return "일시정지"
        case "done":
            return "연습완료"
        default:
            return "준비"
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text(songStatusText)
                        .foregroundColor(.blue)
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.trailing)
                }
                Spacer()
            }
            // 메인 콘텐츠
            MarqueeTextView(
                text: "\(connectivityManager.selectedSongTitle)",
                font: .title2,
                animate: connectivityManager.playStatus == "play"
            )
            .padding()
        }
    }
}

#Preview {
    WatchPlayView()
        .environmentObject(ConnectivityManager())
}
