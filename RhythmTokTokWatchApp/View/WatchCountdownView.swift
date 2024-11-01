//
//  WatchCountdownView.swift
//  RhythmTokTokWatchApp
//
//  Created by Byeol Kim on 10/31/24.
//

import SwiftUI
import WatchKit

struct WatchCountdownView: View {
    @Binding var countdownNumber: Int?
    
    var body: some View {
        ZStack {
            Image("BasicBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if let countdownNumber = countdownNumber {
                Text("\(countdownNumber)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WatchCountdownView(countdownNumber: .constant(3))
}
