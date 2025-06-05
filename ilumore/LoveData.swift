//
//  LoveData.swift
//  ilumore
//
//  Created by Love, Su Lei on 6/4/25.
//

import Foundation

struct LoveData: Codable,Equatable {
    var userCode: String
    var partnerCode: String
    var partnerUid: String?
    var color: String
    var count: Int
    var lastUpdated: Date?
    var username: String
    var email: String
}
