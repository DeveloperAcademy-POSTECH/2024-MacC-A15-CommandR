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
        VStack(spacing: 10)  {
            HStack(alignment: .center) {
                Spacer()
                Text(scoreStatusText)
                    .foregroundColor(.blue)
                    .font(.headline)
                    .padding(.top, 10)
            }
            Spacer()
            
            // 곡 타이틀 표시
            MarqueeTextView(
                text: connectivityManager.selectedScoreTitle,
                fontSize: 20,
                isAnimating: connectivityManager.playStatus == .play
            )
            .frame(height: 24)
            
            Spacer()
            
            Button(action: {
                connectivityManager.playButtonTapped()
            }
            ){
                Image(systemName: connectivityManager.playStatus != .play ? "play.fill" : "pause.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .foregroundColor(.white)
            }
            .frame(width: 142, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue)
            )
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WatchPlayView()
        .environmentObject(ConnectivityManager())
}
