//
//  Untitled.swift
//  RhythmTokTok
//
//  Created by Hyungeol Lee on 10/20/24.
//
import SwiftUI

struct MeasureButton: View{
    var currentRow: Int
    var currentCol: Int
    @Binding var selectedMeasures: [[Int]]
    
    var startBound : [Int] {
        return selectedMeasures[0]
    }
    
    var endBound : [Int] {
        return selectedMeasures[1]
    }
    
    var isSelected: Bool {
        //구간이 다 선택되지 않았을 때
        if startBound == [-1, -1] {
            return false
        }
        
        if endBound == [-1, -1] {
            if currentRow == startBound[0] && currentCol == startBound[1] {
                return true
            }
            return false
        }
        
        //구간이 다 선택되어 있을 때
        if startBound[0] < currentRow && currentRow < endBound[0] {
            return true
        }
        
        if startBound[0] == endBound[0] {
            if currentRow != startBound[0]{
                return false
            }
            if startBound[1] <= currentCol && currentCol <= endBound[1] {
                return true
            }
            return false
        }
        
        if startBound[0] == currentRow {
            if startBound[1] <= currentCol {
                return true
            }
            return false
        }
        
        if endBound[0] == currentRow {
            if currentCol <= endBound[1] {
                return true
            }
            return false
        }
        return false
    }
    
    var body: some View {
        Button{
            handleClick()
            print(selectedMeasures)
        } label : {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isSelected ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : LinearGradient (
                        gradient: Gradient(colors: [Color.blue, Color.gray]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(maxWidth: .infinity,  maxHeight: 50)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color(.red) : Color.clear, lineWidth: 4)
        )
    }
    
    func handleClick() {
        //시작점 설정되어있지 않은 경우
        if startBound == [-1, -1] {
            selectedMeasures[0] = [currentRow, currentCol]
            return
        }
        //시작점이 설정되어 있는 경우
        else {
            if selectedMeasures[0] == [currentRow, currentCol] {
                if selectedMeasures[1] == [-1, -1] {
                    selectedMeasures[0] = [-1, -1]
                } else {
                    selectedMeasures[1] = [-1, -1]
                }
                return
            }
            if selectedMeasures[1] == [currentRow, currentCol] {
                selectedMeasures[1] = [-1, -1]
                return
            }
            //선택한 위치가 시작점보다 이전일 경우
            if currentRow < startBound[0] {
                selectedMeasures[0] = [currentRow, currentCol]
                return
            }
            else if (currentRow == startBound[0]) && (currentCol < startBound[1]) {
                selectedMeasures[0] = [currentRow, currentCol]
                return
            }
            //선택한 위치가 시작점보다 이후일 경우
            else {
                selectedMeasures[1] = [currentRow, currentCol]
                return
            }
        }
    }
}
