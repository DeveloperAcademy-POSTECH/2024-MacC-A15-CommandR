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
                HStack {
                    Spacer()
//                    Text("\(connectivityManager.hapticManager.isHapticActive)")
//                        .foregroundColor(.blue)
//                        .font(.headline)
//                        .padding(.top, 10)
//                        .padding(.trailing)
                    Text("\(connectivityManager.hapticSequence.count)")
                        .foregroundColor(.blue)
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.trailing)
                         
                    Text(scoreStatusText)
                        .foregroundColor(.blue)
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.trailing)
                }
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
