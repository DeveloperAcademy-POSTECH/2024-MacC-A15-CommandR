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
    var title: String {
        return "Moon River"
    }
    var bpm: Int {
        return 60
    }
    var tempo: String {
        return "느리게"
    }
    @State private var selectedMeasures: [[Int]] = [[-1, -1], [-1, -1]]
    
    var body: some View {
        VStack{
            //타이틀
            Text(title)
                .font(.largeTitle .bold())
            //bpm 정보
            HStack {
                Text(tempo) + Text("(\(bpm)bpm)").foregroundColor(.gray)
                Spacer()
            }.padding(.leading)
            
            //악보 뷰
            ForEach (measureCounts.indices) { i in
                HStack(spacing: 0) {
                    Image("g-clef")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                    ForEach(0..<measureCounts[i]) { j in
                        MeasureButton(currentRow: i, currentCol: j, selectedMeasures: $selectedMeasures)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            
            //조작 버튼이 들어있는 행
            HStack {
                //컴포넌트 정렬을 위한 빈 공간
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                
                //재생 버튼
                Button {
                    print("play!")
                } label : {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity,  maxHeight: 50)
                        .overlay(
                            Image(systemName: "play.fill")
                                .tint(.white)
                        )
                }.padding(.trailing)
                
                //repeat 버튼
                HStack {
                    Button {
                        print("repeat")
                    } label : {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.clear)
                            .frame(maxWidth: .infinity,  maxHeight: 50)
                            .overlay(
                                Image(systemName: "repeat")
                                    .resizable()
                            )
                    }
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.clear)
                        .frame(maxWidth: .infinity,  maxHeight: 50)
                }.padding(.leading)

            }.padding()

        }
    }
}



#Preview {
    ScoreView()
}
