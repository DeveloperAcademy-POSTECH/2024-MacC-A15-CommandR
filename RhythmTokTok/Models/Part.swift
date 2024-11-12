//
//  Part.swift
//  RhythmTokTok
//
//  Created by sungkug_apple_developer_ac on 10/12/24.
//

struct Part {
    let id: String
    var measures: [Int: [Measure]] // 줄번호를 key값으로 Dictionary 형태로 마디정보를 가지고 있음
}
