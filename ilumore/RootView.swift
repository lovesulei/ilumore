//
//  RootView.swift
//  ilumore
//
//  Created by Love, Su Lei on 6/4/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if !appState.isSignedIn {
                AuthView {
                    appState.isSignedIn = true
                    loadUserData()
                }
            } else if isLoading{
                ProgressView("Loading...")
            } else if appState.isConnected {
                MainScreen().environmentObject(appState)
            } else {
                ConnectScreen().environmentObject(appState)
            }
        }.onAppear {
            if Auth.auth().currentUser != nil {
                appState.isSignedIn = true
                loadUserData()
            } else {
                appState.isSignedIn = false
            }
        }
    }
    
    func loadUserData() {
        isLoading = true
        guard let uid = Auth.auth().currentUser?.uid  else {
            isLoading = false
            return
        }
        
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument {snapshot, error in
            defer { isLoading = false }
            
            if let snapshot = snapshot, snapshot.exists {
                do {
                    let loveData = try snapshot.data(as: LoveData.self)
                    appState.userCode = loveData.userCode
                    appState.partnerCode = loveData.partnerCode
                    appState.partnerUid = loveData.partnerUid ?? ""
                    appState.color = loveData.color
                    appState.count = loveData.count
                    appState.lastUpdated = loveData.lastUpdated ?? Date()
                    appState.isConnected = !loveData.partnerCode.isEmpty
                } catch {
                    print("Error decoding LoveData:\(error)")
                }
            }
        }
    }
}

#Preview {
    RootView()
}
