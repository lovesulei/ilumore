//
//  FirebaseManager.swift
//  ilumore
//
//  Created by Love, Su Lei on 6/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    let db = Firestore.firestore()
    
    let users = "users" // this is the collection name
    
    func docRef(userCode: String) -> DocumentReference {
        return db.collection(users).document(userCode)
    }
}
