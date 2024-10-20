//
//  ScoreView.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 10/19/24.
//

import SwiftUI

struct ScoreView: View {
    @State var selectedMeasures: [[Int]] = [[-1, -1], [-1, -1]]
    @State var measureCounts: [Int] = []
    let currentScore: Score
    
    var body: some View {
        ScrollView {
            // 악보 뷰
            ForEach(measureCounts.indices, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    Image("gclef")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32)
                    ForEach(0..<measureCounts[rowIndex], id: \.self) { colIndex in
                        MeasureButton(currentRow: index, currentCol: colIndex, selectedMeasures: $selectedMeasures)
                    }
                }
                .padding(.bottom, 15)
            }
        }
        .onAppear {
            measureCounts = getMeasureCountPerLine()
        }
    }
    
    private func getMeasureCountPerLine() -> [Int] {
        var measureCounts: [Int] = []
        
        // parts.last의 모든 키와 마디 넘버를 추출한 배열을 만들기
        let measureDetails = currentScore.parts.last?.measures.flatMap { (lineNumber, measures) in
            measures.map { measure in
                (lineNumber: lineNumber, measureNumber: measure.number)
            }
        }.sorted(by: { $0.measureNumber < $1.measureNumber }) ?? []
        
        var lineNumber = 0
        var measureCnt = 0
        
        for measure in measureDetails {
            print("line: \(measure.lineNumber), measure: \(measure.measureNumber)")
            if lineNumber != measure.lineNumber {
                lineNumber = measure.lineNumber
                if measureCnt != 0 {
                    measureCounts.append(measureCnt)
                }
                measureCnt = 1
            } else {
                print("+")
                measureCnt += 1
            }
        }
        if measureCnt > 0 {
            measureCounts.append(measureCnt)
        }
        print ("check: \(measureCounts)")
        return measureCounts
    }
}

#Preview {
    ScoreView(currentScore: Score())
}
