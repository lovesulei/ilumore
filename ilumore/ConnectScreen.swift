//
//  ConnectScreen.swift
//  ilumore
//
//  Created by Love, Su Lei on 6/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ConnectScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var inputPartnerCode = ""
    @State private var errorMessage = ""
    
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0xFE / 255, green: 0xDC / 255, blue: 0xDB / 255)
                                   .edgesIgnoringSafeArea(.all)
                VStack(spacing: 24) {
                    Text("Your Code:")
                        .font(.custom("PixelifySans-Medium", size: 20))
                        .padding()
                    
                    Text(appState.userCode)
                        .font(.custom("PixelifySans-Medium", size: 28))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    
                    TextField("Enter partner's code", text: $inputPartnerCode)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .autocapitalization(.allCharacters)
                        .font(.custom("PixelifySans-Medium", size: 18))
                        .padding(.horizontal)
                        
                    
                    Button(action: connectToPartner) {
                        Text("Connect")
                            .font(.custom("PixelifySans-Medium", size: 20))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }.padding(.horizontal)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.custom("PixelifySans-Medium", size: 16))
                            .foregroundColor(.red)
                            .padding(.top)
                    }
                    
                    Spacer()
                }.padding()
                    .navigationBarTitle("Connect", displayMode: .inline)
                    .navigationBarItems(trailing:
                                            Button("Sign Out") {
                        signOut()
                    }.foregroundColor(.red)
                    .font(.custom("PixelifySans-Medium", size: 20))

                    )
            }
            
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            appState.isSignedIn = false
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    private func connectToPartner() {
        errorMessage = ""
        let currentUser = Auth.auth().currentUser
        guard let myUid = currentUser?.uid else { return }
        
        guard !inputPartnerCode.isEmpty else {
            errorMessage = "Please enter a code."
            return
        }
        
        if inputPartnerCode == appState.userCode {
            errorMessage = "You can't connect to yourself."
            return
        }
        
        db.collection("users")
            .whereField("userCode", isEqualTo: inputPartnerCode)
            .getDocuments { partnerSnapshot, partnerError in
                if let partnerError = partnerError {
                    errorMessage = "Error searching for partner: \(partnerError.localizedDescription)"
                    
                    return
                }
                
                
                guard let partnerDocs = partnerSnapshot?.documents, let partnerDoc = partnerDocs.first else {
                    errorMessage = "Partner code not found."
                    return
                }
                
                let partnerData = partnerDoc.data()
                let partnerUid = partnerDoc.documentID
                appState.partnerUid = partnerUid
                
                let partnerAlreadyConnected = (partnerData["partnerCode"] as? String ?? "").isEmpty == false
                
                if partnerAlreadyConnected {
                    errorMessage = "This partner is already connected."
                    return
                }
                
                db.collection("users")
                    .whereField("userCode", isEqualTo: appState.userCode)
                    .getDocuments { userSnapshot, userError in
                        if let userError = userError {
                            errorMessage = "Error finding your data : \(userError.localizedDescription)"
                            return
                        }
                        
                        guard let userDocs = userSnapshot?.documents, let userDoc = userDocs.first
                        else {
                            errorMessage = "Your user data not found"
                            return
                        }
                        
                        let userData = userDoc.data()
                        let userUid = userDoc.documentID
                        let userAlreadyConnected = (userData["partnerCode"] as? String ?? "").isEmpty == false
                        
                        if userAlreadyConnected {
                            errorMessage = "You are already connected to someone."
                            return
                        }
                        
                        // Random color assignment
                        let colors = ["orange", "black"].shuffled()
                        let userColor = colors[0]
                        
                        let partnerColor = colors[1]
                        
                        let userRef = db.collection("users").document(userDoc.documentID)
                        let partnerRef = db.collection("users").document(partnerDoc.documentID)
                        
                        let batch = db.batch()
                        
                        batch.updateData([
                            "partnerCode": inputPartnerCode,
                            "partnerUid": partnerUid,
                            "color": userColor,
                            "count": 0,
                            "lastUpdated": NSNull()
                        ], forDocument: userRef)
                        
                        batch.updateData([
                            "partnerCode": appState.userCode,
                            "partnerUid": userUid,
                            "color": partnerColor,
                            "count": 0,
                            "lastUpdated": NSNull()
                        ], forDocument: partnerRef)
                        
                        batch.commit { commitError in
                            if let commitError = commitError {
                                errorMessage = "Failed to connect :\(commitError.localizedDescription)"
                            } else {
                                appState.partnerCode = inputPartnerCode
                                appState.partnerUid = partnerUid
                                appState.isConnected = true
                            }
                        }
                        
                    }
                
                
                
            }
    }
    
}

