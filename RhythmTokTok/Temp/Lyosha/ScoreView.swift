//
//  ScoreView.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 10/19/24.
//

import SwiftUI

struct ScoreView: View {
    @State private var selectedMeasures: [[Int]] = [[-1, -1], [-1, -1]]

    var measureCounts: [Int] {
        return [3, 4, 5, 3]
    }
    
    var body: some View {
        ScrollView {
            // 악보 뷰
            ForEach (measureCounts.indices) { rowIndex in
                HStack(spacing: 0) {
                    Image("gclef")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32)
                    
                    ForEach(0..<measureCounts[rowIndex]) { colIndex in
                        MeasureButton(currentRow: rowIndex, currentCol: colIndex, selectedMeasures: $selectedMeasures)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }
}


#Preview {
    ScoreView()
}
