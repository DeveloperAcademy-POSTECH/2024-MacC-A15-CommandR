//
//  ScoreView.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 10/19/24.
//

import SwiftUI

struct ScoreView: View {
    @ObservedObject var viewModel: MeasureViewModel  // ObservableObject를 사용하여 상태를 관찰
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
                        MeasureButton(currentRow: rowIndex, currentCol: colIndex, selectedMeasures: $selectedMeasures)
                    }
                }
                .padding(.bottom, 15)
            }
        }
        .onAppear {
            measureCounts = getMeasureCountPerLine()
        }
        .onChange(of: selectedMeasures) {
            setSelectedMeasureNumber()
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
            if lineNumber != measure.lineNumber {
                lineNumber = measure.lineNumber
                if measureCnt != 0 {
                    measureCounts.append(measureCnt)
                }
                measureCnt = 1
            } else {
                measureCnt += 1
            }
        }
        if measureCnt > 0 {
            measureCounts.append(measureCnt)
        }
        
        return measureCounts
    }
    
    private func setSelectedMeasureNumber() {
        if selectedMeasures[0] == [-1, -1] {
            viewModel.selectedMeasures = (-1, -1)
        } else {
            if selectedMeasures[0] != [-1, -1] && selectedMeasures[1] == [-1, -1] {
                let startRow = selectedMeasures[0][0]
                let startCol = selectedMeasures[0][1]
                let startNum = getMeasureNum(startRow, startCol)
                
                viewModel.selectedMeasures = (startNum, startNum)
                print("구간 하나만 선택 \(viewModel.selectedMeasures)")
            } else if  selectedMeasures[0] != [-1, -1] && selectedMeasures[1] != [-1, -1] {
                let startRow = selectedMeasures[0][0]
                let startCol = selectedMeasures[0][1]
                let startMeasureNum = getMeasureNum(startRow, startCol)
                
                let endRow = selectedMeasures[1][0]
                let endCol = selectedMeasures[1][1]
                let endMeasureNum = getMeasureNum(endRow, endCol)
                
                print("구간 선택 \(startMeasureNum) ~ \(endMeasureNum)")
                viewModel.selectedMeasures = (startMeasureNum, endMeasureNum)
            }
        }
    }
    
    private func getMeasureNum(_ row: Int, _ col: Int) -> Int {
        var num = 0
        for index in 0..<row {
            num += measureCounts[index]
        }
        num += col
        return num
    }
}

//#Preview {
//    ScoreView(currentScore: Score())
//}
