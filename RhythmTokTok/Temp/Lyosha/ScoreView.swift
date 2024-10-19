//
//  ScoreView.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 10/19/24.
//

import SwiftUI

struct ScoreView: View {
    var measureCounts: [Int] {
        return [3, 4, 5, 3]
    }
    
    var body: some View {
        ForEach (measureCounts, id: \.self) { measureCount in
            HStack(spacing: 0) {
                ForEach(0..<measureCount) { _ in
                    Button{
                        
                    } label : {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(maxWidth: .infinity,  maxHeight: 50)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ScoreView()
}
