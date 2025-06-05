//
//  ilumoreApp.swift
//  ilumore
//
//  Created by Love, Su Lei on 6/3/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct ilumoreApp: App {
    @StateObject private var appState = AppState()
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
