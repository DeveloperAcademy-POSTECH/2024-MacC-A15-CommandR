//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 10/20/24.
//
import SwiftUI

struct MeasureButton: View {
    @Binding var selectedMeasures: [[Int]]
    var currentRow: Int
    var currentCol: Int
    
    var startBound: [Int] {
        return selectedMeasures[0]
    }
    
    var endBound: [Int] {
        return selectedMeasures[1]
    }
    
    /// 현재 버튼이 선택된 구간 내에 해당하는지를 나타내는 Bool 값
    var isSelected: Bool {
        // MARK: 구간이 다 선택되지 않았을 때
        // 구간의 시작이 선택되어 있지 않다면 나머지를 볼 필요 없이 false
        if startBound == [-1, -1] {
            return false
        }
        
        // 구간이 다 선택되지 않았을 때
        // 구간의 끝이 선택되어 있지 않다면, 해당 버튼의 열과 행이 선택된 시작 구간에 일치하는지만 판단하기
        if endBound == [-1, -1] {
            if currentRow == startBound[0] && currentCol == startBound[1] {
                return true
            }
            return false
        }
        
        // MARK: 구간이 다 선택되어 있을 때
        // 선택된 구간이 동일한 행 내에서 존재하는 경우
        if startBound[0] == endBound[0] {
            // 현재 버튼이 위치한 행이 선택된 구간의 행에 해당하지 않는 경우
            if currentRow != startBound[0] {
                return false
            }
            // 현재 버튼이 위치한 행이 선택된 구간의 행에 해당함
            // 현재 버튼이 위치한 열이 선택된 구간의 열의 범위에 해당하는 경우
            if startBound[1] <= currentCol && currentCol <= endBound[1] {
                return true
            }
            // 현재 버튼이 위치한 열이 선택된 구간의 열의 범위에 해당하지 않음
            return false
        }
        
        // 선택된 구간이 서로 다른 행에 걸쳐 있는 경우
        // 현재 버튼이 위치한 행이 선택된 구간의 시작 행에 해당하는 경우
        if startBound[0] == currentRow {
            // 현재 버튼이 위치한 열이 선택된 구간의 시작 열보다 오른쪽에 위치해야 함
            if startBound[1] <= currentCol {
                return true
            }
            return false
        }
        
        // 현재 버튼이 위치한 행이, 선택된 구간의 시작 행과 선택된 구간의 끝 행 사이에 있을 경우
        if startBound[0] < currentRow && currentRow < endBound[0] {
            return true
        }
        
        // 현재 버튼이 위치한 행이, 선택된 구간의 끝 행에 해당하는 경우
        if endBound[0] == currentRow {
            // 현재 버튼이 위치한 열이 선택된 구간의 끝 열보다 왼쪽에 위치해야 함
            if currentCol <= endBound[1] {
                return true
            }
            return false
        }
        
        // default value
        return false
    }
    
    var body: some View {
        Button {
            handleClick()
            print(selectedMeasures)
        } label: {
            Rectangle()
                .fill(
                    isSelected ?
                    Color.progress
                    : Color.white
                )
                .frame(maxWidth: .infinity, minHeight: 53)
                .overlay(
                    GeometryReader { geometry in
                        let lineSpacing = geometry.size.height / 4
                        Path { path in
                            for rowIndex in 1...3 {
                                let yOffset = lineSpacing * CGFloat(rowIndex)
                                path.move(to: CGPoint(x: 0, y: yOffset))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: yOffset))
                            }
                        }
                        .stroke(Color.black, lineWidth: 1)
                    }
                )
        }
        .overlay(
            Rectangle()
                .stroke(Color(.black), lineWidth: 1)
        )
    }
    
    // 버튼을 클릭할 시 구간 선택을 하는 로직임
    func handleClick() {
        // MARK: 시작점이 설정되어있지 않은 경우
        if startBound == [-1, -1] {
            // 현재 버튼의 위치를 시작점으로 잡아 준다
            selectedMeasures[0] = [currentRow, currentCol]
        }
        
        // MARK: 시작점이 설정되어 있는 경우
        else {
            // 선택한 마디가 시작점과 같은 경우
            if selectedMeasures[0] == [currentRow, currentCol] {
                // 끝점이 설정되어 있지 않다면 시작점을 해제함
                if selectedMeasures[1] == [-1, -1] {
                    selectedMeasures[0] = [-1, -1]
                    // 끝점이 설정되어 있다면 끝점을 해제함
                } else {
                    selectedMeasures[1] = [-1, -1]
                }
            }
            
            // 선택한 마디가 끝점과 같은 경우
            else if selectedMeasures[1] == [currentRow, currentCol] {
                // 끝점을 해제함
                selectedMeasures[1] = [-1, -1]
            }
            
            // 선택한 마디가 시작점보다 이전일 경우 (이전의 행인 경우)
            else if currentRow < startBound [0] {
                // 그 마디를 시작점으로 설정함
                selectedMeasures[0] = [currentRow, currentCol]
            }
            
            // 선택한 마디가 시작점보다 이전일 경우 (이전의 열인 경우)
            else if (currentRow == startBound[0]) && (currentCol < startBound[1]) {
                // 그 마디를 시작점으로 설정함
                selectedMeasures[0] = [currentRow, currentCol]
            }
            // 선택한 마디가 시작점보다 이후일 경우 ➡️ 그부분을 끝점으로 설정함
            else {
                selectedMeasures[1] = [currentRow, currentCol]
            }
        }
    }
}
