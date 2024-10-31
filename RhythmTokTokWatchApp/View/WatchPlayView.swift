//
//  WatchPlayView.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 10/15/24.
//
import SwiftUI

struct WatchPlayView: View {
    @EnvironmentObject var connectivityManager: WatchConnectivityManager
    
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
                .padding(.top, 20)
                Spacer()
                // 메인 콘텐츠
                MarqueeTextView(
                    text: connectivityManager.selectedScoreTitle,
                    font: .system(size: 20),
                    isAnimating: connectivityManager.playStatus == .play
                )
                
                Spacer()
                Button(action: {
                    if connectivityManager.playStatus == .play {
                        // 현재 상태가 재생 중일 때 일시정지
                        connectivityManager.pauseButtonTapped()
                    } else {
                        // 현재 상태가 일시정지 또는 다른 상태일 때 재생
                        connectivityManager.playButtonTapped()
                    }
                }
                ) {
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
        }
    }
}

struct WatchPlayView_Previews: PreviewProvider {
    static var previews: some View {
        // 샘플 데이터를 가진 ConnectivityManager 생성
        let manager = ConnectivityManager()
        manager.selectedScoreTitle = "This is a long song title that should scroll across the screen"
        manager.playStatus = .play
        return WatchPlayView()
            .environmentObject(manager)
    }


//#Preview {
//    WatchPlayView()
//        .environmentObject(ConnectivityManager())
//}
