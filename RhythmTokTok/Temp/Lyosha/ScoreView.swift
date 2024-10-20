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
        return "Slow"
    }
    
    var body: some View {
        VStack{
            Text(title)
                .font(.largeTitle .bold())
            HStack {
                Text(tempo) + Text("(\(bpm)bpm)").foregroundColor(.gray)
                Spacer()
            }.padding(.leading)
            ForEach (measureCounts, id: \.self) { measureCount in
                HStack(spacing: 0) {
                    ForEach(0..<measureCount) { _ in
                        Button{
                            print("selected")
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
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: 50)
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
