//
//  WatchPlayView.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 10/15/24.
//
import SwiftUI

struct WatchPlayView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    
    private var scoreStatusText: String {
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
                HStack(alignment: .center) {
                    Spacer()
                    Image(systemName: connectivityManager.hapticManager.isHapticActive ? "play.fill" : "stop.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(.blue)

                    Text(scoreStatusText)
                        .foregroundColor(.blue)
                        .font(.headline)
                        .padding(.trailing)
                }
                .padding(.top, 20)
                Spacer()
            }
            // 메인 콘텐츠
            MarqueeTextView(
                text: "\(connectivityManager.selectedScoreTitle)",
                font: .title2,
                isAnimating: connectivityManager.playStatus == "play"
            )
            .padding()
        }
    }
}

#Preview {
    WatchPlayView()
        .environmentObject(ConnectivityManager())
}
