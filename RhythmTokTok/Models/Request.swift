//
//  Request.swift
//  RhythmTokTok
//
//  Created by Byeol Kim on 11/8/24.
//

import Foundation

struct Request {
    let id: Int
    var title: String
    let requestDate: Date
    var status: RequestStatus
    var xmlURL: String?
}
