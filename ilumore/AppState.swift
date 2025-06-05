//
//  AppState.swift
//  ilumore
//
//  Created by Love, Su Lei on 6/5/25.
//

import Foundation

class AppState: ObservableObject {
    @Published var userCode: String = ""
    @Published var partnerCode: String = ""
    @Published var partnerUid: String = ""
    @Published var isSignedIn: Bool = false  // Add this to control sign-in flow
    @Published var isConnected: Bool = false
    @Published var color: String = ""
    @Published var count: Int = 0
    @Published var lastUpdated: Date = Date()
    
    func reset() {
        userCode = ""
        partnerCode = ""
        partnerUid = ""
        isSignedIn = false
        isConnected = false
        color=""
        count=0
        lastUpdated=Date()
    }
}
