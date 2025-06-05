//
//  AuthView.swift
//  ilumore
//
//  Created by Love, Su Lei on 6/4/25.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isSigningUp = false
    @State private var username = ""

    var onAuthSuccess: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0xFE / 255, green: 0xDC / 255, blue: 0xDB / 255)
                       .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Image("heart_pixel")
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("Welcome to ILUMore")
                        .font(.custom("PixelifySans-Medium", size: 20))
                        .foregroundColor(.black)
                    Image("heart_pixel")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                
                
                if isSigningUp {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .autocapitalization(.none)
                        .font(.custom("PixelifySans-Medium", size: 16))
                }
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .font(.custom("PixelifySans-Medium", size:16))
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .font(.custom("PixelifySans-Medium", size: 16))
                
                Button(action: {
                    isSigningUp ? signUp() : signIn()
                }) {
                    Text(isSigningUp ? "Sign Up" : "Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(12)
                        .font(.custom("PixelifySans-Medium", size: 18))
                }
                
                Button(action: {
                    isSigningUp.toggle()
                    errorMessage = ""
                }) {
                    Text(isSigningUp ? "Already have an account? Sign In" : "No account? Sign Up")
                        .foregroundColor(.blue)
                        .font(.custom("PixelifySans-Medium", size: 14))
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .font(.custom("PixelifySans-Medium", size:14))
                        .padding(.horizontal)
                }
            }.padding(.horizontal, 24)
        }
    }
    
    func signUp() {
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            guard let user = result?.user else {
                errorMessage = "Unexpected error: User not found after sign up."
                return
            }
            
            let userCode = generateUserCode(length:6)
            let db = Firestore.firestore()
            let loveDataRef = db.collection("users").document(user.uid)
            
            loveDataRef.setData([
                "userCode": userCode,
                "partnerCode": "",
                "email": email,
                "username": username,
                "color": "",
                "count": 0,
                "lastUpdated": Date()
            ]) { err in
                if let err = err {
                    errorMessage = "Failed to save user data: \(err.localizedDescription)"
                    return
                }
                appState.userCode = userCode
                appState.partnerCode = ""
                appState.isSignedIn = true
                onAuthSuccess()
                
            }
            
               
        }
    }
    
    func signIn() {
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                onAuthSuccess()
            }
            
        }
    }
    
    func generateUserCode(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
     
}

