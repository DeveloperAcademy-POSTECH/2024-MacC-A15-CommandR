//
//  Request.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import Foundation

struct Request {
    let id: UUID
    let title: String
    let date: Date
    var status: RequestStatus
}
