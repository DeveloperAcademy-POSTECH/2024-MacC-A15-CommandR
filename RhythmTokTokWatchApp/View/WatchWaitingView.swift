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
//    @StateObject var logger = Logger.shared
    
    var body: some View {
        ZStack {
            Image("BasicBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // TODO: 테스트 코드임 삭제 필요
//            VStack {
//                Text("세션 활성화 횟수 : \(logger.activatedSession)")
//                    .font(.system(size: 8))
//                Text("예약 시간 : \(logger.watchScheduledTime)")
//                    .font(.system(size: 8))
//                Text("시작 시간 : \(logger.watchHapticTime)")
//                    .font(.system(size: 8))
//            }
            // 여기 까지
            
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
