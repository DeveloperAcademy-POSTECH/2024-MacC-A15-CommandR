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
        case .ready, .stop:
            return "준비"
        case .play:
            return "재생중"
        case .pause:
            return "일시정지"
        case .done:
            return "연습완료"
        }
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .center) {
                    Spacer()
                    Text(scoreStatusText)
                        .foregroundColor(.blue)
                        .font(.headline)
                        .padding(.trailing)
                }
//                .padding(.top, 20)
                
                // 메인 콘텐츠
                MarqueeTextView(
                    text: "\(connectivityManager.selectedScoreTitle)",
                    font: .title2,
                    isAnimating: connectivityManager.playStatus == .play
                )
                .padding()

                // 재생 및 일시정지 버튼
                if connectivityManager.playStatus == .ready ||
                    connectivityManager.playStatus == .pause ||
                    connectivityManager.playStatus == .stop ||
                    connectivityManager.playStatus == .done {
                    Button(action: {
                        // 재생 버튼 눌렀을 때
                        connectivityManager.playButtonTapped()
                    }) {
                        Image(systemName: "play.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                } else if connectivityManager.playStatus == .play {
                    Button(action: {
                        // 일시정지 버튼 눌렀을 때
                        connectivityManager.playButtonTapped()
                    }) {
                        Image(systemName: "pause.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
            }
        }
    }
}

#Preview {
    WatchPlayView()
        .environmentObject(ConnectivityManager())
}
